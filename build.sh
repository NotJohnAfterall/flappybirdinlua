if [ ! -d "bin" ]; then
  mkdir bin
fi

rm -rf bin/*

wget -P bin https://github.com/love2d/love/releases/download/11.5/love-11.5-win32.zip

unzip bin/love-11.5-win32.zip -d bin

rm bin/love-11.5-win32.zip

zip -r bin/flappybirdinlua.love ./*

cat bin/love-11.5-win32/love.exe bin/flappybirdinlua.love > bin/love-11.5-win32/game.exe

rm bin/flappybirdinlua.love
rm -rf bin/love-11.5-win32/love.exe
rm -rf bin/love-11.5-win32/lovec.exe
mv bin/love-11.5-win32 bin/flappybirdinlua

(cd bin/flappybirdinlua && zip -r ../flappybirdinlua.zip ./*)