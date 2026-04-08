# OMF ROMs Extension
# 2026/07/28

[ $API -ge 36 ] && return

ui_print "+ ROMs Extension"

[ `sed '/^id=/{s|id=||;q}' $MODPROP` = ohmyfont ] || return
# OOS10
[ -f $ORISYSETC/fonts_slate.xml ] && {
    cp ${SYSXMLOLD:=$SYSXML} $SYSETC/fonts_slate.xml
    OOS=true; ver slatexml; return
}

# OOS11
[ -f $ORISYSETC/fonts_base.xml ] && {
    cp ${SYSXMLOLD:=$SYSXML} $SYSETC/fonts_base.xml
    OOS11=true; ver basexml; return
}

# COS11/OOS12
[ -f $ORISYSEXTETC/fonts_base.xml ] && {
    falias sys-sans-en
    cp ${SYSXMLOLD:=$SYSXML} $SYSEXTETC/fonts_base.xml
    COS=true; ver xbasexml; return
}

# LG
local lg=lg-sans-serif
grep -q $lg $SYSXML && {
    LG=true; ver lg; $SANS || return
    local lgq="/\"$lg\">/"; local lgf="$lgq,$FAE"
    xml "$lgf{$lgq!d};$SAF{$SAQ!H};${lgq}G"
    return
}

# LG (lgexml)
[ -f $ORISYSETC/fonts_lge.xml ] && {
    cp ${SYSXMLOLD:=$SYSXML} $SYSETC/fonts_lge.xml
    LGE=true; ver lgexml; return
}

$SANS || return

# MIUI
grep -q MIUI $ORISYSXML && {
    ver miui
    [ $API -eq 29 ] && return
    MIUI=`sed -n "/$FA.*\"miui\"/,$FAE{/400.*$N/{s|.*>||;p}}" $SYSXML`

    # MIUI A14
    case `getprop ro.build.version.incremental` in *U*XM)
        xml "/<$FA>/,${FAE}{d;q}"
        return;;
    esac

    # Lock all axes but wght
    [ -f $ORISYSFONT/$MIUI ] && [ $API -ge 31 ] && {
        totf || return
        ui_print '  Special treatments for MIUI (~60s)...'
        fonttools varLib.instancer -q -o $SYSFONT/$MIUI $TMPDIR/$SS \
            $(echo $(eval echo $(up $`ab $SS`r)) | \
            sed 's|\([[:alpha:]]\) \([[:digit:]]\)|\1=\2|g' | \
            sed 's|wght=[0-9.]*||') || abort
        return
    }

    # MIUI v13
    case `getprop ro.build.version.incremental` in V13*XM)
        #afdko || return
        xml "${SAF}H;/und-Yezi/,$FAE{${FAE}G}"
        xml ":a;N;\$!ba;s|name=\"$SA\"||2"
        return;;
    esac

    # HyperOS Global 2
    case `getprop ro.build.version.incremental` in OS2*XM)
        [ $SS ] && cp $SYSFONT/$SS $SYSFONT/$RR && return
        cp $SYSFONT/$Re$X $SYSFONT/$RR
        return;;
    esac

    [ -f $ORISYSFONT/$MIUI ] && ln -s $X $SYSFONT/$MIUI
    [ -f $ORISYSFONT/RobotoVF$X ] && ln -s $X $SYSFONT/RobotoVF$X

    return
}

# Samsumg
grep -q Samsung $ORISYSXML && {
    fontab sec-roboto-light $SS r
    fontab sec-roboto-light $SS b M
    fontab sec-roboto-condensed $SS r
    fontab sec-roboto-condensed $SS b
    fontab sec-roboto-condensed-light $SS r L
    falias sec-no-flip
    falias sec
    falias roboto-num3L
    falias roboto-num3R
    SAM=true; ver sam; return
}
