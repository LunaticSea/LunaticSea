if exist build/LunaticSea.exe (
  del /f "build/LunaticSea.exe"
)
if not exist build/* (
  mkdir build 
)
lit make
move LunaticSea.exe ./build