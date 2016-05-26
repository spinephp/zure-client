#! /home/lxm/spineapp

make()
{
    cd $1
    hem build
    sudo cp public/application.js /www/zure-server/scripts/$2.js
    sudo cp public/application.css /www/zure-server/css/$2.css
    cd ..
}
if [ $# -lt 1 ]; then
        make "contact" "contact"
        make "goods" "good"
        make "main" "main"
        make "managers" "office"
        make "member" "member"
        make "news" "news"
        make "order" "order"
        make "orderinfo" "orderinfo"
        make "orderdetail" "orderdetail"
else
    if [ $# -lt 2 ]
        then 
            p=$1
    else
        p=$2
    fi
    make $1 $p
fi

