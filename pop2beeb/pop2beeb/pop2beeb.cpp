// pop2beeb.cpp : Defines the entry point for the console application.
//

//#include "stdafx.h"
#include "CImg.h"

using namespace cimg_library;

static unsigned char imagetab[10 * 1024];
static int image_addrs[256];
static int image_size[256][2];
static unsigned char image_data[256][1000];

static int pixel_size[256][2];
static unsigned char pixels[256][10000];

static unsigned char colours[256][10000];

static int total_colours[7];

#define BLACK0 0
#define PURPLE 1
#define GREEN 2
#define WHITE0 3
#define BLACK1 4
#define BLUE 5
#define ORANGE 6
#define WHITE1 7

#define GET_16BIT(ptr)	(*(ptr) + *(ptr+1)*256)

unsigned char palette[8][3] = 
{
	{ 0, 0, 0 },				// black
	{ 255, 68, 253 },			// purple
	{ 20, 245, 60 },			// green
	{ 255, 255, 255 },			// white
	{ 0, 0, 0 },				// black
	{ 20, 207, 253 },			// blue
	{ 255, 106, 60 },			// orange
	{ 255, 255, 255 },			// white
};

unsigned char odd_columns[8] =
{
	BLACK0,
	BLACK0,
	GREEN,						// orange
	WHITE0,
	BLACK0,
	PURPLE,						// blue
	WHITE0,
	WHITE0
};

unsigned char even_columns[8] =
{
	BLACK0,
	BLACK0,
	PURPLE,						// blue
	WHITE0,
	BLACK0,
	GREEN,						// orange
	WHITE0,
	WHITE0
};

unsigned char mode1[8] =
{
	0,							// black
	1,							// purple = magenta
	2,							// green
	3,							// white
	0,							// black
	1,							// blue = blue or cyan
	2,							// orange = red or yellow or stiple?
	3							// white
};

int convert_apple_to_pixels(unsigned char *apple_data, int apple_width, int apple_height, unsigned char *pixel_data)
{
	int pixel_width = apple_width * 7;

	for (int y = 0; y < apple_height; y++)
	{
		int x = 0;

		for (int a = 0; a < apple_width; a++)
		{
			unsigned char byte = apple_data[y * apple_width + a];
			
			int group = byte & 0x80;			// 0=purple+green, 1=blue+orange

			unsigned char bit = 1;

			for (int b = 0; b < 7; b++, bit <<= 1, x++)
			{
				pixel_data[y * pixel_width + x] = (group ? 4 : 0) + (byte & bit ? 1 : 0);
			}
		}
	}

#if 0
	for (int y = 0; y < apple_height; y++)
	{
		for (int x = 0; x < pixel_width; x++)
		{
			printf("%d ", pixel_data[y*pixel_width + x]);
		}
		printf("\n");
	}
#endif

	return pixel_width;
}

void flip_pixels_in_y(unsigned char *pixel_data, int pixel_width, int pixel_height)
{
	for (int y = 0; y < pixel_height / 2; y++)
	{
		for (int x = 0; x < pixel_width; x++)
		{
			unsigned char byte1 = pixel_data[y * pixel_width + x];
			unsigned char byte2 = pixel_data[(pixel_height - 1 - y) * pixel_width + x];

			pixel_data[(pixel_height - 1 - y) * pixel_width + x] = byte1;
			pixel_data[y * pixel_width + x] = byte2;
		}
	}
}

void convert_pixels_to_colour(unsigned char *pixel_data, int pixel_width, int pixel_height, unsigned char *colour_data, bool invert)
{
	for (int y = 0; y < pixel_height; y++)
	{
		for (int x = 0; x < pixel_width; x++)
		{
			unsigned char byte0 = x > 0 ? pixel_data[y*pixel_width + x - 1] : 0;
			unsigned char byte1 = pixel_data[y*pixel_width + x];
			unsigned char byte2 = x < (pixel_width - 1) ? pixel_data[y*pixel_width + x + 1] : 0;

			int group0 = byte0 & 4;
			int group1 = byte1 & 4;
			int group2 = byte2 & 4;

			int pixel0 = byte0 & 1;
			int pixel1 = byte1 & 1;
			int pixel2 = byte2 & 1;

			if ((x & 1) == invert)
			{
				colour_data[y*pixel_width + x] = group1 | odd_columns[pixel0 + pixel1 * 2 + pixel2 * 4];
			}
			else
			{
				colour_data[y*pixel_width + x] = group1 | even_columns[pixel0 + pixel1 * 2 + pixel2 * 4];
			}

			total_colours[colour_data[y*pixel_width + x]]++;
		}
	}
}

int convert_colour_to_mode1(unsigned char *colour_data, int pixel_width, int pixel_height)
{
	int pixel_pitch = pixel_width;

	for (int x = pixel_pitch - 1; x >= 0; x--)
	{
		int y;

		for (y = 0; y < pixel_height; y++)
		{
			if (colour_data[y*pixel_pitch + x] != BLACK0 && colour_data[y*pixel_pitch + x] != BLACK1)
				break;
		}

		if (y == pixel_height)
			pixel_width--;
	}

	int mode1_width = (pixel_width + 3) / 4;
	int mode1_height = pixel_height;
	int mode1_bytes = mode1_width * mode1_height;

	printf("%d x %d = %d bytes, %d x %d pixels\n", mode1_width, mode1_height, mode1_bytes, pixel_width, pixel_height);

	return mode1_bytes;
}

int main(int argc, char **argv)
{
	cimg_usage("POP asset convertor.\n\nUsage : pop2beeb [options]");
	const char *const inputname = cimg_option("-i", (char*)0, "Input filename");
	const bool test = cimg_option("-test", false, "Save test images");

	if (cimg_option("-h", false, 0)) std::exit(0);
	if (inputname == NULL)  std::exit(0);

	FILE *input = fopen(inputname, "rb");
	if (!input) std::exit(0);

	char parityfile[256];
	sprintf(parityfile, "%s.txt", inputname);

	FILE *parity = fopen(parityfile, "rb");

	fread(imagetab, 1, 10 * 1024, input);				// forgotten how to file length of file!

	int num_images = imagetab[0];

	printf("Num images = %d\n", num_images);
	printf("Image addresses:\n");

	for (int i = 0; i < num_images; i++)
	{
		image_addrs[i] = GET_16BIT(imagetab + 1 + i * 2);
		printf("[%d] 0x%x\n", i, image_addrs[i]);
	}
	image_addrs[num_images] = GET_16BIT(imagetab + 1 + num_images * 2);
	printf("First free address = 0x%x\n", image_addrs[num_images]);

	unsigned char *image_ptr = imagetab + 1 + num_images * 2 + 2;

	int total_bytes = 0;
	int total_width = 0;
	int max_height = 0;

	for (int c = 0; c < 8; c++)
	{
		total_colours[c] = 0;
	}

	for (int i = 0; i < num_images; i++)
	{
		image_size[i][0] = *image_ptr++;
		image_size[i][1] = *image_ptr++;

		int bytes = image_size[i][0] * image_size[i][1];
		total_bytes += bytes;

		for (int d = 0; d < bytes; d++)
		{
			image_data[i][d] = *image_ptr++;
		}

		pixel_size[i][0] = convert_apple_to_pixels(image_data[i], image_size[i][0], image_size[i][1], pixels[i]);
		pixel_size[i][1] = image_size[i][1];

		if (pixel_size[i][1] > max_height)
			max_height = pixel_size[i][1];

		total_width += pixel_size[i][0] + 8;

		printf("Image %d: %d x %d = %d bytes, %d x %d pixels\n", i, image_size[i][0], image_size[i][1], bytes, pixel_size[i][0], pixel_size[i][1]);

		flip_pixels_in_y(pixels[i], pixel_size[i][0], pixel_size[i][1]);
		
		bool invert = 0;

		if (parity)
		{
			invert = fgetc(parity) == '1' ? 1 : 0;
		}

		convert_pixels_to_colour(pixels[i], pixel_size[i][0], pixel_size[i][1], colours[i], invert);
	}

	printf("Total bytes = %d\n", total_bytes);
	printf("Total colours:\n");

	for (int c = 0; c < 8; c++)
	{
		printf("[%d] %d\n", c, total_colours[c]);
	}

	if (test)
	{
		printf("Test: %d x %d\n", total_width, max_height);

		CImg<unsigned char> img(total_width, max_height, 1, 3, 0);

		int current_x = 0;

		for (int i = 0; i < num_images; i++)
		{
			int height = pixel_size[i][1];
			int current_y = max_height - height;

			for (int y = 0; y < height; y++)
			{
				int width = pixel_size[i][0];
				for (int x = 0; x < width; x++)
				{
					img(current_x + x, current_y + y, 0) = palette[colours[i][y*width + x]][0];
					img(current_x + x, current_y + y, 1) = palette[colours[i][y*width + x]][1];
					img(current_x + x, current_y + y, 2) = palette[colours[i][y*width + x]][2];
				}
			}

			current_x += pixel_size[i][0] + 8;
		}

		char testname[256];
		sprintf(testname, "%s.png", inputname);
		img.save(testname);
	}

	int total_mode1 = 0;

	for (int i = 0; i < num_images; i++)
	{
		printf("Image[%d]: MODE1=", i);
		total_mode1 += convert_colour_to_mode1(colours[i], pixel_size[i][0], pixel_size[i][1]);
	}

	printf("Total MODE1 bytes = %d\n", total_mode1);
	printf("Size increase = %f%%\n", 100.0f * total_mode1 / (float)total_bytes);

	fclose(input);
	if (parity)
		fclose(parity);
		
	return 0;
}
