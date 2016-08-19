#! /home/lxm/spineapp

make()
{
    spine app $1
	cd $1
	npm install .
	cd ..
	sudo cp index.coffee $1/app/
	sudo rm -rf $1/css/*.styl
	sudo rm -rf $1/app/views/sample.jade
}

if [ $# -lt 1 ]; then
        make "contact"
        make "customhome"
        make "goods"
        make "goodsevaluation"
        make "main"
        make "managers"
        make "member"
        make "news"
        make "order"
        make "orderinfo"
        make "orderdetail"
        make "password"
        make "writegoodsuse"

		git init
		git remote add git@github.com:spinephp/zure-client.git
		git pull git://github.com/spinephp/zure-client.git 
else
    make $1
fi

