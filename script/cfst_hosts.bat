
@echo off
Setlocal Enabledelayedexpansion

::�ж��Ƿ��ѻ�ù���ԱȨ��

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" 

if '%errorlevel%' NEQ '0' (  
    goto UACPrompt  
) else ( goto gotAdmin )  

::д�� vbs �ű��Թ���Ա�������б��ű���bat��

:UACPrompt  
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
    "%temp%\getadmin.vbs" 
    exit /B  

::�����ʱ vbs �ű����ڣ���ɾ��
  
:gotAdmin  
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )  
    pushd "%CD%" 
    CD /D "%~dp0" 


::�������ж��Ƿ��Ի�ù���ԱȨ�ޣ����û�о�ȥ��ȡ��������Ǳ��ű���Ҫ����


::��� nowip_hosts.txt �ļ������ڣ�˵���ǵ�һ�����иýű�
if not exist "nowip_hosts.txt" (
    echo �ýű�������Ϊ CloudflareST ���ٺ��ȡ��� IP ���滻 Hosts �е� Cloudflare CDN IP��
    echo ʹ��ǰ�����Ķ���https://github.com/imashen/CloudflareSpeedTest/issues/42#issuecomment-768273768
    echo.
    echo ��һ��ʹ�ã����Ƚ� Hosts ������ Cloudflare CDN IP ͳһ��Ϊһ�� IP��
    set /p nowip="����� Cloudflare CDN IP ���س�������������Ҫ�ò��裩:"
    echo !nowip!>nowip_hosts.txt
    echo.
)  

::�� nowip_hosts.txt �ļ���ȡ��ǰ Hosts ��ʹ�õ� Cloudflare CDN IP
set /p nowip=<nowip_hosts.txt
echo ��ʼ����...


:: ��� RESET �Ǹ���Ҫ "�Ҳ������������� IP ��һֱѭ��������ȥ" ���ܵ���׼����
:: �����Ҫ������ܾͰ����� 3 �� goto :STOP ��Ϊ goto :RESET ����
:RESET


:: ��������Լ����ӡ��޸� CloudflareST �����в�����echo.| ���������Զ��س��˳����򣨲�����Ҫ���� -p 0 �����ˣ�
echo.|CloudflareST.exe -o "result_hosts.txt"


:: �жϽ���ļ��Ƿ���ڣ����������˵�����Ϊ 0
if not exist result_hosts.txt (
    echo.
    echo CloudflareST ���ٽ�� IP ����Ϊ 0���������沽��...
    goto :STOP
)

:: ��ȡ��һ�е���� IP
for /f "tokens=1 delims=," %%i in (result_hosts.txt) do (
    SET /a n+=1 
    If !n!==2 (
        SET bestip=%%i
        goto :END
    )
)
:END

:: �жϸոջ�ȡ����� IP �Ƿ�Ϊ�գ��Լ��Ƿ�;� IP һ��
if "%bestip%"=="" (
    echo.
    echo CloudflareST ���ٽ�� IP ����Ϊ 0���������沽��...
    goto :STOP
)
if "%bestip%"=="%nowip%" (
    echo.
    echo CloudflareST ���ٽ�� IP ����Ϊ 0���������沽��...
    goto :STOP
)


:: ������δ����� "�Ҳ������������� IP ��һֱѭ��������ȥ" ����Ҫ�Ĵ���
:: ���ǵ���ָ���������ٶ����ޣ���һ������ȫ�������� IP ��û�ҵ�ʱ��CloudflareST �ͻ�������� IP ���
:: ��˵���ָ�� -sl ����ʱ����Ҫ�Ƴ�������δ��뿪ͷ����� :: ð��ע�ͷ��������ļ������жϣ��������ز���������10 ������ô�����ֵ������Ϊ 11��
::set /a v=0
::for /f %%a in ('type result_hosts.txt') do set /a v+=1
::if %v% GTR 11 (
::    echo.
::    echo CloudflareST ���ٽ��û���ҵ�һ����ȫ���������� IP�����²���...
::    goto :RESET
::)


echo %bestip%>nowip_hosts.txt
echo.
echo �� IP Ϊ %nowip%
echo �� IP Ϊ %bestip%

CD /d "C:\Windows\System32\drivers\etc"
echo.
echo ��ʼ���� Hosts �ļ���hosts_backup��...
copy hosts hosts_backup
echo.
echo ��ʼ�滻...
(
    for /f "tokens=*" %%i in (hosts_backup) do (
        set s=%%i
        set s=!s:%nowip%=%bestip%!
        echo !s!
        )
)>hosts

echo ���...
echo.
:STOP
pause 