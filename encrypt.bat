@echo off
REM ===========================================================
REM index.html を staticrypt でパスワード暗号化するラッパー
REM Windows用バッチファイル
REM
REM 使い方:
REM   encrypt.bat "<password>"
REM ===========================================================
setlocal

if "%~1"=="" (
    echo 使い方: %~nx0 ^<password^>
    exit /b 1
)

set PASSWORD=%~1
cd /d "%~dp0"

if not exist index.html (
    echo index.html が見つかりません
    exit /b 1
)

REM 既に暗号化済みなら、元の平文に戻してから再暗号化
if exist index.html.unencrypted (
    echo [info] 既に暗号化済みです。元のindex.htmlに戻してから再暗号化します。
    copy /Y index.html.unencrypted index.html >nul
) else (
    copy /Y index.html index.html.unencrypted >nul
)

REM staticrypt 検出
where staticrypt >nul 2>nul
if %errorlevel%==0 (
    set STATICRYPT=staticrypt
) else (
    if exist "node_modules\.bin\staticrypt.cmd" (
        set STATICRYPT=node_modules\.bin\staticrypt.cmd
    ) else (
        echo staticrypt が見つかりません。
        echo インストール: npm install -g staticrypt
        echo  または: npm install staticrypt
        exit /b 1
    )
)

set OUT=%TEMP%\dba_enc_%RANDOM%
mkdir "%OUT%"

%STATICRYPT% index.html -p "%PASSWORD%" --short -d "%OUT%" ^
    --template-title "ドラゴンボート レース分析ツール" ^
    --template-instructions "委員会から配布されたパスワードを入力してください" ^
    --template-placeholder "パスワード" ^
    --template-button "開く" ^
    --template-remember "ログインを記憶 (30日間)" ^
    --template-error "パスワードが違います" ^
    --remember 30

copy /Y "%OUT%\index.html" index.html >nul
rmdir /S /Q "%OUT%"

echo [ok] index.html を暗号化しました
echo [ok] 元の平文は index.html.unencrypted に退避してあります
echo.
echo 次のステップ:
echo   - GitHub Pages にプッシュ or Netlify Drop でアップロード
endlocal
