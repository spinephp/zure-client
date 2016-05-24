#! /home/lxm/spineapp

make()
{
    cd $1
    hem build
    sudo cp public/$2.js /www/zure-server/scripts
    sudo cp public/$2.css /www/zure-server/css
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

