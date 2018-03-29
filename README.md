# Prince Of Persia (pop-beeb)
## For 6502 Acorn BBC Master 128Kb 
A port of **Jordan Mechner's** original Apple II version of Prince of Persia to the BBC Master computer.

Ported by **Kieran Connell**.

A development blog (of sorts) can be found on [this](http://www.stardot.org.uk/forums/viewtopic.php?f=53&t=13079) Stardot forum thread.


<p float="left">
<img src="https://github.com/kieranhj/pop-beeb/raw/master/Notes/TitleScreen.png" width="160" height="128" />
<img src="https://github.com/kieranhj/pop-beeb/raw/master/Notes/PrincessScreen.png" width="160" height="128" />
<img src="https://github.com/kieranhj/pop-beeb/raw/master/Notes/LevelScreen1.png" width="160" height="128" />
<img src="https://github.com/kieranhj/pop-beeb/raw/master/Notes/LevelScreen2.png" width="160" height="128" />

# Game Controls

**Player Control Keys**

* `Z` - Left
* `X` - Right
* `:` or `*` - Up / Jump (possibly  `quote` on your PC keyboard)
* `/` or `?` - Down / Crouch
* `]` - Forward Jump (possibly `#` on your PC keyboard)
* `RETURN` - Action / grab ledge / sneak / attack
* `T` - Show time remaining

**Helper Keys**

* `CTRL`+`K` - Redefine keys
* `CTRL`+`A` - Restart level
* `CTRL`+`R` - Return to titles
* `CTRL`+`G` - Save game to disc (must be write enabled)
* `CTRL`+`P` - Pause (`P` to step or any other key to continue)
* `CTRL`+`M` - Music on/off 
* `CTRL`+`S` - Sound on/off
* `CTRL`+`↑` - Volume up
* `CTRL`+`↓` - Volume down
* `CTRL`+`E` - Toggle easy guards on/off (reduce attack probability)

**Debug Keys (Development Build only!)**

* `CTRL`+`N` - Next level
* `CTRL`+`5` - Skip 5 levels
* `CTRL`+`Z` - Zap (Kill) guard
* `CTRL`+`W` - Increase max energy
* `CTRL`+`S` - Increase energy
* `CTRL`+`D` - Decrease energy
* `CTRL`+`U` - Move Player up one row on screen
* `CTRL`+`Q` - Antimatter (press and walk through gates etc.)
* `CTRL`+`1` - Add one minute to time remaining
* `CTRL`+`2` - Remove one minute from time remaining
* `CTRL`+`0` - Set time remaining to 60 seconds...
* `R` - Resurrect (after death)

**Cheat Codes (Released game!)**

* `SKIP` - Next level
* `POP` - Cheat mode enabled (following codes then work)
* `KILL` - Kill guard on screen
* `BOOST` - Boost health meter (increase max energy)
* `REST` - Restore health to max
* `ZAP` - Zap guard to 1 health
* `TINA` - Jump to end of game

# References

[Logo1](http://edit.tf/#8:QIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAigNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICKA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgIoDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAigNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICKA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAkgNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICSA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgJIDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAkgNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICSA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAmgNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICaA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgJoDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAmgNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICaA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAogNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICiA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgKIDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAogNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICiA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECA)

[Logo2](http://edit.tf/#8:QIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAigNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICKA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgIoDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAigNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICKA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAkgNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICSA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgJIDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAkgNf2urV_Qf0CBAgQIECBAgQIECBAgQIECDmx_tdX9elQICSA1_-_tX9B_Gh6HLTux5UE_MgoZeXPThJDH6H-11f0CBAgQIECBAgQIECAagoctO7HlQT8yChl5c9OEkMQIECBAgQIECAmgNf2qBUvQf0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQICaA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgJoDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAmgNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICaA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAogNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICiA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgKIDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAogNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICiA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECA)

[Logo3](http://edit.tf/#8:MIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAigNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICKA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgIoDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAigNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICKA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAkgNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICSA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgJIDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAkgNf2urV_Qf2qBGjRokaBCjQokaBAiRoEWPmx_tdX9elQICSA1_-_tX9B_Gh6HLTux5UG_MgoZeXPThJDH6H-11f0CBAgQIECBAgQIECAagoctO7HlQT8yChl5c9OEkMQIECBAgQIECAmgNf2qBUvQf2iBAgQYOCBAgQYOCBBg4IECBAgQIECBAgQICaA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgJoDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAmgNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICaA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECAogNf2qBUvQf2qBAgQav6BAvS6v69Bq_oECBAgQIECBAgQICiA1_f79X9V_fpf79fq_r2v9rv_r1W_-vQfvqD-_SoP7VAgKIDX9rq1f0H9qg_9eGr-ga_2ur-gQav6DV__tf7XR8_tUCAogNf2urV_Qf2qBHr_6v6Br_a6v6BBq_oMXPmx_tdX9elQICiA1_-_tX9B_-tPn7_q_oGv9rq_oEGr_8Rb36H-11f0CBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECA)

[Keys](http://edit.tf/#8:CHQY1AgQIECBAgoctO7HlQb8yChl5c9OFAgQIECBAgQDEBwIdBjUCBAgQIECChy07seVBvzIKGXlz04UCBAgQIECBAgQHECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBBi8oJW_lkw7kE3Lj0bsvJAgQIECBAgQIECANQ38umXIg6b0EKFDQTcPPpl5IMXlBL05eWHcgh7927Ls2IA6BAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgDy8vnm6CoECBAgQWkCDAgQTMubogQIECBAgQIECBAgQIECAKgQIECBAgQIECBBYQIMCBBS059HRAgQIECBAgQIECBAgQIASBAgQIECBAgQIECpAgwIEFXggXoJXXbwQIECBAgQIECBAgBIECBAgQIECBAgQP0CDAgQRN_fcgXoIfLf1x6ECBAgQIECAGgQIECBAgQIECBBdQIMCBBG38u-HlkQSuu3ggQIECBAgQIAaBAgQIECClFqVaU5AgwIEEHH0079yBAgQIECBAgQIECBAgDIECBAgQIECBAgQVECDAgQVNO3Kg5ZduHTu07s6BAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIA6BAgQIECCHUpTFstAgwIEFLLky5tO7Kg15fPNAgQIECBAgAoECBAgQIIdSlMWwUCDAgQUsvPph5dEGzL2y7ECBAgQIECACgQIECBAgh1KUxbSQIMCBBSy9OvLcg6b0HTT02ZeaBAgQIA6BAgQIECCHUpTFsdAgwIEFPD2yoM-HblQdN6DJp540CBAgDoECBAgQIIdSlMW0ECDAgQUMPXnlQIECBAgQIECBAgQIECACgQIECBAgh1KUxbNQIMCBBN689ONBv3L9-bMgQIECBAgQIAKBAgQIECCHUpTFtNAgwIEFPf13ZEG_cv35syBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQRt_JBt38sqDRl2cECqpZoRUE2DOqwZiDfuQZNPPGgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgCHQ6BAgQUKUWnTQQZ1lBLi2UFSeghz51STOqxUCBAgQIDiA)

[Keys2](http://edit.tf/#8:CHQY1AgQIECBAgoctO7HlQb8yChl5c9OFAgQIECBAgQDEBwIdBjUCBAgQIECChy07seVBvzIKGXlz04UCBAgQIECBAgQHECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBBi8oJW_lkw7kE3Lj0bsvJAgQIECBAgQIECANQ38umXIg6b0EKFDQTcPPpl5IMXlBL05eWHcgh7927Ls2IA6BAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgDy8vnm6CoECBAgQWkCDAgQTMubogQIECBAgQIECBAgQIECAKgQIECBAgQIECBBYQIMCBBS059HRAgQIECBAgQIECBAgQIASBAgQIECBAgQIECpAgwIEFXggXoJXXbwQIECBAgQIECBAgBIECBAgQIECBAgQP0CDAgQRN_fcgXoIfLf1x6ECBAgQIECAGgQIECBAgQIECBBdQIMCBBG38u-HlkQSuu3ggQIECBAgQIAaBAgQIECClFqVaU5AgwIEEHH0079yBAgQIECBAgQIECBAgDIECBAgQIECBAgQVECDAgQVNO3Kg5ZduHTu07s6BAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIA6BAgQIECCHUpTFstAgwIEFLLky5tO7Kg15fPNAgQIECBAgQIECBAgQAYdSlMWwUCDAgQUsvPph5dEGzL2y7ECBAgQIECACgQIECBAgh1KUxbSQIMCBBSy9OvLcg6b0HTT02ZeaBAgQIECBAgQIECCHUpTFsdAgwIEFPD2yoM-HblQdN6DJp540CBAgDoECBAgQIIdSlMW0ECDAgQUMPXnlQIECBAgQIECBAgQIECACgQIECBAgh1KUxbNQIMCBBN689ONBv3L9-bMgQIECBAgQIAKBAgQIECCHUpTFtNAgwIEFPf13ZEG_cv35syBAgQIECBAgQAYdSlMW1aC-JPrzkCDAgQVt-zrtyoOvBfk399yBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECBAgQIECANG38kG3fyyoNGXZwQKqlmhFQTYM6rBmIN-5Bk088aBAgCHQ4lAgQUKUWnTQQZ1lBLi2UFSeghz51STOqxUCBAgQIDiA)

