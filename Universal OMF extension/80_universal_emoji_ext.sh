# Universal emoji extension Extension 
# by khirendra
#credit: @nongthaihoang, @MrCarb0n and MFFM @telegram
# 2021/11/08

EM=your_emoji_name.ttf

cp $OMFDIR/$EM $SYSFONT/NotoColorEmoji.ttf && {
    ui_print '+ iOS emoji 14.0 '
    if [ -f $ORISYSFONT/SamsungColorEmoji.ttf ]; then
    mv $SYSFONT/NotoColorEmoji.ttf $SYSFONT/SamsungColorEmoji.ttf;
    fi
    ver emoji
}
