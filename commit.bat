luvit make dir

cd translation
git add .
git commit
git push -u origin HEAD:main
cd ..

cd libs

cd lunalink
git add .
git commit
git push -u origin HEAD:main
cd ..

cd lunaticdb
git add .
git commit
git push -u origin HEAD:main
cd ..

cd plugins-api
git add .
git commit
git push -u origin HEAD:main
cd ..

cd Discordia
git add .
git commit
git push -u origin HEAD:master
cd ..

cd internal
git add .
git commit
git push -u origin HEAD:main
cd ..

cd ..
git add .
git commit
