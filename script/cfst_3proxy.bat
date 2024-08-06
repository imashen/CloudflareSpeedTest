
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


::��� nowip_3proxy.txt �ļ������ڣ�˵���ǵ�һ�����иýű�
if not exist "nowip_3proxy.txt" (
    echo �ýű�������Ϊ CloudflareST ���ٺ��ȡ��� IP ���滻 3Proxy �����ļ��е� Cloudflare CDN IP��
    echo ���԰����� Cloudflare CDN IP ���ض�������� IP��ʵ��һ�����ݵļ�������ʹ�� Cloudflare CDN ����վ������Ҫһ�������������� Hosts �ˣ���
    echo ʹ��ǰ�����Ķ���https://github.com/imashen/CloudflareSpeedTest
    echo.
    set /p nowip="���뵱ǰ 3Proxy ����ʹ�õ� Cloudflare CDN IP ���س�������������Ҫ�ò��裩:"
    echo !nowip!>nowip_3proxy.txt
    echo.
)  

::�� nowip_3proxy.txt �ļ���ȡ��ǰʹ�õ� Cloudflare CDN IP
set /p nowip=<nowip_3proxy.txt
echo ��ʼ����...


:: ��� RESET �Ǹ���Ҫ "�Ҳ������������� IP ��һֱѭ��������ȥ" ���ܵ���׼����
:: �����Ҫ������ܾͰ����� 3 �� goto :STOP ��Ϊ goto :RESET ����
:RESET


:: ��������Լ����ӡ��޸� CloudflareST �����в�����echo.| ���������Զ��س��˳����򣨲�����Ҫ���� -p 0 �����ˣ�
echo.|CloudflareST.exe -o "result_3proxy.txt"


:: �жϽ���ļ��Ƿ���ڣ����������˵�����Ϊ 0
if not exist result_3proxy.txt (
    echo.
    echo CloudflareST ���ٽ�� IP ����Ϊ 0���������沽��...
    goto :STOP
)

:: ��ȡ��һ�е���� IP
for /f "tokens=1 delims=," %%i in (result_3proxy.txt) do (
    set /a n+=1 
    If !n!==2 (
        set bestip=%%i
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
::for /f %%a in ('type result_3proxy.txt') do set /a v+=1
::if %v% GTR 11 (
::    echo.
::    echo CloudflareST ���ٽ��û���ҵ�һ����ȫ���������� IP�����²���...
::    goto :RESET
::)


echo %bestip%>nowip_3proxy.txt
echo.
echo �� IP Ϊ %nowip%
echo �� IP Ϊ %bestip%



:: �뽫�����ڵ� D:\Program Files\3Proxy ��Ϊ��� 3Proxy ��������Ŀ¼
CD /d "D:\Program Files\3Proxy"
:: ��ȷ�����иýű�ǰ���Ѿ����Թ� 3Proxy �����������в�ʹ�ã�



echo.
echo ��ʼ���� 3proxy.cfg �ļ���3proxy.cfg_backup��...
copy 3proxy.cfg 3proxy.cfg_backup
echo.
echo ��ʼ�滻...
(
    for /f "tokens=*" %%i in (3proxy.cfg_backup) do (
        set s=%%i
        set s=!s:%nowip%=%bestip%!
        echo !s!
        )
)>3proxy.cfg

net stop 3proxy
net start 3proxy

echo ���...
echo.
:STOP
pause 