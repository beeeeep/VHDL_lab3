@echo off
REM ****************************************************************************
REM Vivado (TM) v2021.1 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Wed Oct 13 00:46:01 +0200 2021
REM SW Build 3247384 on Thu Jun 10 19:36:33 MDT 2021
REM
REM IP Build 3246043 on Fri Jun 11 00:30:35 MDT 2021
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
REM elaborate design
echo "xelab -wto 8ec574a92b7e4a72807129ffe1e8a4d0 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot tb_ALU_behav xil_defaultlib.tb_ALU -log elaborate.log"
call xelab  -wto 8ec574a92b7e4a72807129ffe1e8a4d0 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot tb_ALU_behav xil_defaultlib.tb_ALU -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0