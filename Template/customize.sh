# Oh My Font Installation Script
# by nongthaihoang @ GitLab

# Verbose log
set -xv

# Old Magisk
[ -d ${ORIDIR:=`magisk --path`/".magisk/mirror"}/system ] || \
      ORIDIR=

# Original paths
[ -d ${ORIPRD:=$ORIDIR/product} ] || \
      ORIPRD=$ORIDIR/system/product
[ -d ${ORISYSEXT:=$ORIDIR/system_ext} ] || \
   ORISYSEXT=$ORIDIR/system/system_ext

      ORISYS=$ORIDIR/system
  ORIPRDFONT=$ORIPRD/fonts
   ORIPRDETC=$ORIPRD/etc
   ORIPRDXML=$ORIPRDETC/fonts_customization.xml
  ORISYSFONT=$ORISYS/fonts
   ORISYSETC=$ORISYS/etc
ORISYSEXTETC=$ORISYSEXT/etc
   ORISYSXML=$ORISYSETC/fonts.xml

# Modules paths
        MODS=/data/adb/modules 
     ModPath=$MODS/$MODID
         SYS=$MODPATH/system
         PRD=$SYS/product
     PRDFONT=$PRD/fonts
      PRDETC=$PRD/etc
      PRDXML=$PRDETC/fonts_customization.xml
     SYSFONT=$SYS/fonts
      SYSETC=$SYS/etc
      SYSEXT=$SYS/system_ext
   SYSEXTETC=$SYSEXT/etc
      SYSXML=$SYSETC/fonts.xml
     MODPROP=$MODPATH/module.prop
       FONTS=$MODPATH/fonts
       TOOLS=$MODPATH/tools

        SERV=$MODPATH/service.sh
        POST=$MODPATH/post-fs-data.sh
        UNIN=$MODPATH/uninstall.sh

      OMFDIR=/sdcard/OhMyFont
      OMFVER=`grep ^versionCode= $MODPROP | sed 's|.*=||'`
       UCONF=$OMFDIR/config.cfg
      
# System paths
     SysFont=/system/fonts
      SysEtc=/system/etc
      SysXml=/system/etc/fonts.xml
     PrdFont=/product/fonts
        Null=/dev/null

# Create necessary paths
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC $FONTS $TOOLS $OMFDIR

# Extract payload
SH=$MODPATH/customize.sh
tail -n +$((`grep -an ^PAYLOAD:$ $SH | cut -d : -f 1`+1)) $SH | tar xJf - -C $MODPATH || abort

# Placebo for the AFDKO
afdko() {
    [ $1 ] && ui_print '! The AFDKO extension is required!'
    false
}

# Add text to the module version
ver() { sed -i "/^version=/s|$|-$1|" $MODPROP; }

# Sed (fontxml)
xml() {
    [ "${XML:=$SYSXML}" ]
    local xml
    for xml in $XML; do
        case $XML_LIST in
            *$xml*) ;;
                # remove comments
            *)  sed -i '/^[[:blank:]]*<!--.*-->/d;/<!--/,/-->/d' $XML
                # change single quote to double quotes
                sed -i "s|'|\"|g" $XML
                # cut one line <font> tag to new lines
                sed -i "/<$F .*>/s|>|\n&|" $XML
                # merge multiple lines <font> tag into one line
                sed -i "/[[:blank:]]<$F /{:a;N;/>/!ba;s|\n||g}" $XML
                # cut <\font> tag to new line
                sed -i "/<$F.*$FE/s|$FE|\n&|" $XML
                # merge 2 lines <font> tag to one line
                sed -i "/<$F .*>$/{N;s|\n||}" $XML
                # join <\font> to <font> line if any
                sed -i "/<$F /{N;s|\n$FE|$FE|}" $XML
                # remove blank before font file
                sed -i "/<$F /s|>[[:blank:]][[:blank:]]*|>|" $XML
                # water mark
                sed -i "2i<!-- OMF v$OMFVER -->\n" $XML
                # save fontxml paths to a list
                XML_LIST="$xml $XML_LIST" ;;
        esac
        sed -i "$@" $xml
    done
}

# Uppercase
up() { echo $@ | tr [:lower:] [:upper:]; }

# Run custom scripts, 3 stages:
# script names starts in 0: run in romprep()
# script names starts in 1-8: run before rom()
# script names starts in 9: run after rom()
src() {
    local l=`find $OMFDIR -maxdepth 1 -type f -name '*.sh' -exec basename {} \; | sort`
    if   [ "$1" = 0 ]; then l=`echo "$l" | grep '^0'`
    elif [ "$1" = 9 ]; then l=`echo "$l" | grep '^9'`
    else                    l=`echo "$l" | grep '^[^09]'`; fi
    local i
    for i in $l; do ui_print "+ Source $i"
        . $OMFDIR/$i
    done
}

# Custom services
svc() {
    $BOOTMODE || return
    local omfserv=$OMFDIR/service.d/*.sh
    local omfpost=$OMFDIR/post-fs-data.d/*.sh
    local omfunin=$OMFDIR/uninstall.d/*.sh

    # Bootloop prevention
    echo 'MODDIR=${0%/*}' >> $SERV
    echo '( sleep 60; ! [ `getprop sys.boot_completed` ] && touch $MODDIR/disable ) &' >> $SERV

    # Check for custom services
    ls $omfserv &>$Null || \
    ls $omfpost &>$Null || \
    ls $omfunin &>$Null && {
        ui_print '+ Services'

        # service.d
        ls $omfserv &>$Null && {
            #echo 'MODDIR=${0%/*}' >> $SERV
            for i in $omfserv; do
                cp $i $MODPATH
                i=`basename $i`
                chmod +x $MODPATH/$i
                echo "\$MODDIR/$i &" >> $SERV
                ui_print "  $i"
            done
        }

        # post-fs-data.d
        ls $omfpost &>$Null && {
            echo 'MODDIR=${0%/*}' >> $POST
            for i in $omfpost; do
                cp $i $MODPATH
                i=`basename $i`
                chmod +x $MODPATH/$i
                echo "\$MODDIR/$i" >> $POST
                ui_print "  $i"
            done
        }

        # uninstall.d
        ls $omfunin &>$Null && {
            echo 'MODDIR=${0%/*}' >> $UNIN
            for i in $omfunin; do
                cp $i $MODPATH
                i=`basename $i`
                chmod +x $MODPATH/$i
                echo "\$MODDIR/$i &" >> $UNIN
                ui_print "  $i"
            done
        }
    }
}

# Copy fonts from $FONTS to $SYSFONT, no overwrite
cpf() {
    [ $# -eq 0 ] && return 1
    local i
    for i in $@; do
        false | cp -i $FONTS/$i ${CPF:=$SYSFONT} &>$Null
    done
}

# Detect ROM before installation
romprep() {
    # Source extensions (0)
    src 0

    # Pixel
    [ -f $ORIPRDFONT/$GSR ] && grep -q $Gs $ORIPRDXML && \
        PXL=true
}

rom() {
    # Source extensions (1 to 8)
    src

    # Allow disable PXL from the config
    local pxl=`valof PXL`
    [ $PXL ] && [ "$pxl" = false ] && PXL=

    # Add custom GS xml into SYSXML
    $SANS && [ $GS != true ] && {
        local gsxml=$FONTS/gsvf.xml m=source-sans-pro-semi-bold
        xml "/$m/r $gsxml"
        # remove variable* font families if not Pixel
        [ $PXL ] || xml "/$FA.*\"variable.*\"/,${FAE}d"
        # disable GMS font services (Thanks to @MrCarb0n)
        $BOOTMODE && (
            ${rmf:="rm /data/user/0/com.google.android.gms/files/fonts/opentype/Google_Sans*"}
            gms=com.google.android.gms/com.google.android.gms.fonts
            gms1=$gms.provider.FontsProvider
            gms2=$gms.update.UpdateSchedulerService
            echo "( until pm disable $gms1; do sleep 30; done; pm disable $gms2; $rmf ) &" >> $SERV
            echo "( until pm enable $gms1; do sleep 5; done; pm enable $gms2 ) &" >> $UNIN
        )

        [ $PXL ] || {
            local fa=$Gs.* up=$SS it=$SSI
            mksty $Gs-flex; fontinst
        }
    }

    [ $PXL ] && pxl

    # Source extension (9)
    src 9
}

# Pixel
pxl() {
    ui_print '  Pixel'
    ver pxl

    # GS=true quit
    $SANS && [ $GS != true ] || return

    cp $ORIPRDXML $PRDXML
    local XML fa axis_del up it i ups its italic

    # Switch $XML to $PRDXML
    XML=$PRDXML 

    # Remove gs, variable-body* (PRDXML)
    for fa in $Gs $Gs-[mbt].* variable-b.*[eml]; do
        xml "/$FA.*\"$fa\"/,${FAE}d"
        xml "/<alias.*to=\"$fa\"/d"
    done

    # GS = false: remove flex, variable* (PRDXML)
    [ $GS = false ] && {
        for fa in $Gs-flex variable.*; do
            xml "/$FA-list.*\"$fa\"/,/\/$FA-list/d"
            xml "/$FA.*\"$fa\"/,${FAE}d"
        done
    }

    # Switch $XML back to $SYSXML
    XML=

    # GS = mix: remove flex, variable*, keep variable-body* (SYSXML)
    [ $GS = mix ] && {
        for fa in $Gs-flex variable-[dhtl].* variable.*emphasized; do
            xml "/$FA.*\"$fa\"/,${FAE}d"
        done
    }

    # Installation
    up=$SS it=$SSI

    # google-sans
    fa=$Gs.* ups=G its=GI
    fontinst r m sb b

    # google-sans-text
    fa=$Gs-text.* ups=GT its=GTI
    fontinst r m sb b

    # variable-body*
    italic=false
    # Regular
    set variable-body-large      VBL \
        variable-body-medium     VBM \
        variable-body-small      VBS
    while [ $2 ]; do
        fa=$1 ups=$2
        mksty 4 4; fontab $fa $up r
        shift 2
    done
    italic=
        
    # GS = mix: stop here
    [ $GS = mix ] && return

    # google-sans-flex
    fa=$Gs-flex ups=GF its=GFI
    mkstya; fontinst

    # Link GS to RR
    ln -s $SysFont/$RR $PRDFONT/$GSR

    # variable* have no Italics
    italic=false

    # Regular
    set variable-display-large   VDL \
        variable-display-medium  VDM \
        variable-display-small   VDS \
        variable-headline-large  VHL \
        variable-headline-medium VHM \
        variable-headline-small  VHS \
        variable-title-large     VTL
    while [ $2 ]; do
        fa=$1 ups=$2
        mksty 4 4; fontab $fa $up r
        shift 2
    done

    # Medium
    set variable-title-medium    VTM \
        variable-title-small     VTS \
        variable-label-large     VLL \
        variable-label-medium    VLM \
        variable-label-small     VLS
    while [ $2 ]; do
        fa=$1 ups=$2
        mksty 5 5; fontab $fa $up m
        shift 2
    done

    # variable-body* is moved above for GS = mix
    ## Regular
    #set variable-body-large      VBL \
    #    variable-body-medium     VBM \
    #    variable-body-small      VBS
    #while [ $2 ]; do
    #    fa=$1 ups=$2
    #    mksty 4 4; fontab $fa $up r
    #    shift 2
    #done
        
    # Medium
    set variable-display-large-emphasized   VDLE \
        variable-display-medium-emphasized  VDME \
        variable-display-small-emphasized   VDSE \
        variable-headline-large-emphasized  VHLE \
        variable-headline-medium-emphasized VHME \
        variable-headline-small-emphasized  VHSE \
        variable-title-large-emphasized     VTLE
    while [ $2 ]; do
        fa=$1 ups=$2
        mksty 5 5; fontab $fa $up m
        shift 2
    done

    # SemiBold
    set variable-title-medium-emphasized    VTME \
        variable-title-small-emphasized     VTSE \
        variable-label-large-emphasized     VLLE \
        variable-label-medium-emphasized    VLME \
        variable-label-small-emphasized     VLSE
    while [ $2 ]; do
        fa=$1 ups=$2
        mksty 6 6; fontab $fa $up sb
        shift 2
    done

    # Medium
    set variable-body-large-emphasized      VBLE \
        variable-body-medium-emphasized     VBME \
        variable-body-small-emphasized      VBSE
    while [ $2 ]; do
        fa=$1 ups=$2
        mksty 5 5; fontab $fa $up m
        shift 2
    done

    # Link GSF to RR
    ln -s $SysFont/$RR $PRDFONT/$GSF
}

# Common variables
vars() {
    # xml
    FA=family FAE="/\/$FA/" F=font FE="<\/$F>"
    W=weight S=style I=italic N=normal ID=index=
    FF=fallbackFor FW='t el l r m sb b eb bl'
    FB=fallback pSN=postScriptName
    readonly FA FAE F FE W S I N ID FF FW FB pSN

    # Font families
    SE=serif SA=sans-$SE SAQ="/\"$SA\">/" SAF="$SAQ,$FAE"
    SC=$SA-condensed MO=monospace SO=$SE-$MO
    readonly SE SA SAQ SAF SC MO SO

    # Font styles
    Bl=Black Bo=Bold EBo=Extra$Bo SBo=Semi$Bo Me=Medium
    Th=Thin Li=Light ELi=Extra$Li Re=Regular It=Italic
    Cn=Condensed- St=Static
    readonly Bl Bo EBo SBo Me Th Li ELi Re It Cn St

    # Font extensions
    X=.ttf Y=.otf Z=.ttc XY=.[ot]tf XYZ=.[ot]t[tc]
    readonly X Y Z XY XYZ

    # Default font names and families
    Ro=Roboto Ns=NotoSerif
    Ds=DroidSans$X Dm=DroidSansMono Cm=CutiveMono
    RR=$Ro-$Re$X RS=$Ro$St-$Re$X
    GSa=GoogleSans GSF=${GSa}Flex-$Re$X
    GSR=$GSa-$Re$X GSI=$GSa-$It$X
    Gs=google-sans GSC=${GSa}Clock-$Re$X GFC=${GSa}FlexClock-$Re$X
    readonly Ro Ns Ds Dm Cm RR RS GSa GSF GSR GSI Gs GSC

    # family prefix
    Mo=Mono- Se=Serif- So=SerifMono-
    readonly Mo Se So

    # Font names
    SF=SFUI$X SFI=SFUI$It$X SFR=SFUIRounded$X
    SFM=SFUIMono$X SFMI=SFUIMono$It$X
    NY=NewYork$X NYI=NewYork$It$X
    CP=CourierPrime$Z
    readonly SF SFI SFR SFM SFMI NY NYI CP
}

# Prepare fontxml
prep() {
    [ $API -ge 36 ] || ui_print "! Recommend Android 16 or newer!"

    vars 

    # Android 15+, add font_fallback.xml to $SYSXML
    [ $API -ge 35 ] && {
        SysXmlOld=$SysXml
        SysXmlNew=$SysEtc/font_fallback.xml
        SysXml="$SysXml $SysXmlNew"

        SYSXMLOLD=$SYSXML
        SYSXMLNEW=$SYSETC/font_fallback.xml
        SYSXML="$SYSXML $SYSXMLNEW"

        ORISYSXMLOLD=$ORISYSXML
        ORISYSXMLNEW=$ORISYSETC/font_fallback.xml
        ORISYSXML="$ORISYSXML $ORISYSXMLNEW"
    }

    # Unmount fontxml to get the original one before updating
    COMP=`valof COMP`; [ ${COMP:=false} ]
    [ -d $ModPath/system ] && {
        ui_print '  Updating!'
        ! $COMP && ! [ $ORIDIR ] && {
            umount $ORISYSXML $ORIPRDXML &>$Null
            grep -q OMF $ORISYSXML && \
                abort '! Update Failed. Remove the module and try again!'
        }
    }

    romprep

    # Remove fontxml from other modules
    [ "`find $MODS* -not -path "*/$MODID/*" -type f -name "font*xml" -print`" ] && {
        ui_print "! Warning. Conflicted Module Detected!"

        # Compatible mode
        $COMP && {
            ui_print "  Compatible Mode!"
            ver '<!>'
            false | cp -i $SysXml $SYSETC &>$Null
            find $MODS* -not -path "*/$MODID/*" -type f -name "font*xml" -delete
            return
        }
        abort
    }

    false | cp -i $ORISYSXML $SYSETC &>$Null
}

# Run custom logic within the font()
fontcust() {
    # SF Rounded filter
    [ $f = $SF ] && case $* in *SPAC*) f=$SFR ;; esac
}

# Font installation (fontxml)
# $1 family, $2 font, $3 weight, $* font style
font() {
    local fa=${1:?} f=${2:?} w=${3:-r} s=$N r i ps

    # Run custom logic
    fontcust $*

    # ttc
    case $f in *c) i=$ID          ;; esac
    # serif
    case $w in *s) r=$SE w=${w%?} ;; esac
    # italics
    case $w in *i) s=$I  w=${w%?} ;; esac
    # convert weight names to numbers
    case $w in
        t ) w=1 ;; el) w=2 ;; l ) w=3 ;;
        r ) w=4 ;; m ) w=5 ;; sb) w=6 ;;
        b ) w=7 ;; eb) w=8 ;; bl) w=9 ;;
    esac
    fa="/$FA.*\"$fa\"/,$FAE" s="${w}00.*$s"
    # italics
    [ $i ] && s="$s.*$i\"[0-9]*"
    # serif; postScriptName
    [ $r ] && s="$s.*\"$r"; s="$s\"[[:blank:]]*[p>]"

    # cut </font> tag to new line
    xml "$fa{/$s/s|$FE|\n&|}"
    # if axis_del is true then remove all <axis> tags
    $axis_del && xml "$fa{/$s/,/$FE/{/$F/!d}}"
    # replace font name
    xml "$fa{/$s/s|>.*$|>$f|}"
    # check index if ttc
    [ $4 ] && [ $i ] && {
        xml "$fa{/$s/s|$i\".*\"|$i\"$4\"|}"
        return
    }

    # Remove all but axes
    shift 3; [ $# -eq 0 -o $? -ne 0 ] && {
        xml "$fa{/$s/{N;s|\n$FE|$FE|}}"
        return
    }
    # axes
    f="$s.*$f" s="/$f/,/$FE/"; local t v a
    while [ $2 ]; do
        t="tag=\"$1\"" v="stylevalue=\"$2\""
        a="<axis $t $v/>"; shift 2
        xml "$fa{$s{/$t/d};/$f/s|$|\n$a|}"
    done
}

# Input a font name, output a font style prefix
# $1: font, $2: family, $3: style
ab() {
    local n=z
    # check $ups for a custom font style prefix
    [ $ups ] && n=$ups || \
    case $1 in
        $SF |$SFR ) n=u ;;
        $SFI      ) n=i ;;
        $NY |$NYI ) n=s ;;
        $SFM|$SFMI) n=m ;;
    esac
    case "$3" in *i)
        case $n in
            # if $ups, check $its
            $ups) [ $its ] && n=$its ;;
        esac
    esac
    # condensed
    [ "$2" = $SC -a $n = u ] && n=c
    echo $n
}

# Call font(), input a font style from the config()
fontab() {
    local w=${4:-$3}; case $w in *i) w=${w%?} ;; esac
    eval font $1 $2 $3 \$$(up `ab $2 $1 $3`$w)
}

# Font installation, no arguments, gets values from vars
fontinst() {
    # VFs
    case $up in *.*)
        [ $up ] && cpf $up
        [ $it ] && cpf $it
        local i
        for i in ${@:-$FW}; do
            [ $up ] && {
                fontab $fa $up $i
                $condensed && [ $fa = $SA ] && fontab $SC $up $i
            }
            [ $it ] && {
                fontab $fa $it ${i}i
                $condensed && [ $fa = $SA ] && fontab $SC $it ${i}i
            }
        done
        return ;;
    esac

    # Static fonts
    set bli $Bl$It bl $Bl ebi $EBo$It eb $EBo bi $Bo$It b $Bo \
        sbi $SBo$It sb $SBo mi $Me$It m $Me ri $It r $Re \
        li $Li$It l $Li eli $ELi$It el $ELi ti $Th$It t $Th
    while [ $2 ]; do
        cpf $up$2$X && font $fa $up$2$X $1 && \
            $condensed && [ $fa = $SA ] && {
                cpf ${up%?}$Cn$2$X && font $SC ${up%?}$Cn$2$X $1 || \
                    { $FULL && font $SC $up$2$X $1; }
            }
        shift 2
    done
}

# Make font styles (fontxml)
mksty() {
    case $1 in [a-z]*) local fa=$1; shift ;; esac
    local max=${1:-9} min=${2:-1} dw=${3:-1} id=$4 di=${5:-1} fb ps

    [ $fa ] || local fa=$SA
    local fae="/$FA.*\"$fa\"/,$FAE"
    # if font_del then delete all existing <font> tag in a <family> tag
    $font_del && xml "$fae{/$FA/!d}"

    local i=$max j=0 s
    # index ttc
    [ $id ] && j=$id && id=" $ID\"$j\""
    # fallback for
    [ $fallback ] && fb=" $FF=\"$fallback\""
    # postScriptName
    [ $postscript ] && ps=" $pSN=\"$postscript\""
    until [ $i -lt $min ]; do
        for s in $I $N; do
            eval \$$s || continue
            xml "$fae{/$fa/s|$|\n<$F $W=\"${i}00\" $S=\"$s\"$id$fb$ps>$FE|}"
            [ $j -gt 0 ] && j=$(($j-$di)) && id=" $ID\"$j\""
        done
        [ $i -gt 4 -a $(($i-$dw)) -lt 4 ] && \
            i=4 min=4 || i=$(($i-$dw))
    done

    # Remove weights
    for i in $wght_del; do xml "$fae{/${i}00/d}"; done
}

# Call mksty(), only make styles for existing ones
mkstya() {
    # VFs
    case $up in *.*)
        local wght_del i j=1 k=false
        [ $it ] || local italic=false

        for i in $FW; do
            # delete empty font weights
            eval [ \"\$$(up `ab $up`$i)\" ] && k=true || \
                wght_del="$wght_del $j"
            j=$((j+1))
        done
        # if all styles are empty, make a Regular
        $k || {
            wght_del=
            mksty 4 4
            $condensed && [ $fa = $SA ] && mksty $SC 4 4
            return
        }

        mksty
        $condensed && [ $fa = $SA ] && mksty $SC
        return ;;
    esac

    # Static fonts
    local i=9 italic font_del
    set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
        $SBo$It $SBo $Me$It $Me $It $Re \
        $Li$It $Li $ELi$It $ELi $Th$It $Th
    while [ $2 ]; do
        italic=
        # check for existing font files
        [ -f $FONTS/$up$1$X ] || italic=false
        [ -f $FONTS/$up$2$X ] && {
            mksty $i $i
            $condensed && [ $fa = $SA ] && mksty $SC $i $i
            font_del=false
        }
        i=$((i-1)); shift 2
    done
}

# Make a font family fallback (no family name)
# duplicate a family, delete the its 2nd name
fallback() {
    local faq fae fb
    [ $1 ] && local fa=$1; [ $fa ] || local fa=$SA
    faq="\"$fa\"" fae="/$FA.*$faq/,$FAE"
    # add "fallbackFor" to <font> tags
    [ $fa = $SA ] || fb="/<$F/s|>| $FF=$faq>|;"
    # make new family instead of fallback
    [ $name ] && name=name=\"$name\" fb=

    # Replace the 2nd family name
    xml "$fae{${fb}H;2,$FAE{${FAE}G}}"
    xml ":a;N;\$!ba;s|name=$faq|$name|2"
    # if fallback, revert changes on the original family
    [ "$fb" ] && xml "$fae{s| $FF=$faq||
        s| $pSN=\"[^ ]*\"||}"
}

# Call fallback(), make fallback for main font families
fba() {
    # List fallback fonts
    [ "${FBL:=`sed -n "/<$FA *>/,$FAE p" $SYSXML`}" ]
    # Roboto
    if   [ "$fa" = $SA ]; then echo $FBL | grep -q $Ro || fallback
    # NotoSerif
    elif [ "$fa" = $SE ]; then echo $FBL | grep -q $Ns || fallback
    # DroidSansMono
    elif [ "$fa" = $MO ]; then echo $FBL | grep -q $Dm || fallback
    # Cutive Mono
    elif [ "$fa" = $SO ]; then echo $FBL | grep -q $Cm || fallback; fi
    # update the list
    FBL=`sed -n "/<$FA *>/,$FAE p" $SYSXML`
}

# Insert lookup indexes to a feature tag, e.g. calt, liga
otltag() {
    afdko || return
    
    # extract GSUB table
    local f=${1:?}; shift
    ttx -s -t GSUB -f $f &>$Null
    
    # insert lookup index values
    local i t=${f%$X}.G_S_U_B_.ttx \
        f=Feature v=value= id=$ID l=LookupListIndex
    for i in $@; do
        sed -i "/<${f}Tag $v\"$OTLTAG\"\/>/,/<\/$f>/{
        /<\/$f>/s|^|<$l $id\"9\" $v\"$i\"/>\n|}" $t
    done
}

# Font features
# $1 otl, $2 font
otl() {
    [ $# -eq 2 ] && afdko 1 && {
        pyftfeatfreeze -f $1 $2 $2 || abort
        return
    }

    [ "$OTL" ] && totf || return
    ui_print "  OTL ($OTL)"

    local font ttx otl
    for font in $SF $SFI $SFR; do
        font=$TMPDIR/$font ttx=${font%$X}.G_S_U_B_.ttx otl=

        # If $OTLTAG is set, use the otltag()
        [ $OTLTAG ] && {
            pyftfeatfreeze -v -f $OTL $font $Null &> $TMPDIR/otl || abort
            otl=`cat $TMPDIR/otl | grep Lookups: | grep -o [0-9]*`
            [ "$otl" ] && otltag $font $otl && \
                $TOOLS/pyftimport $font $ttx || break
        } || \
            pyftfeatfreeze -f $OTL $font $font || abort
    done

    # Clean. Unset OTL to make the otl() only runs once
    rm $SYSFONT/*.ttx &>$Null
    OTL=
}

# San Francisco
sfui() {
    local up=$SF it=$SFI fa=${1:-$SA}
    [ $fa = $SA ] && local condensed=false

    fba; mkstya; fontinst
    # SF doesn't have condensed italics
    [ $fa = $SA ] && { fa=$SC it=; mkstya; fontinst; }

    # Line spacing
    line
    # Font features
    otl
}

# New York
newyork() {
    local up=$NY it=$NYI fa=${1:-$SE}
    fba; mkstya; fontinst

    [ "${LINESER:=1.0}" != 1.0 ] && totf && {
        ui_print "  Line spacing ($LINESER)"
        line $TMPDIR/$SER $LINESER
        [ $SER != $SERI ] && line $TMPDIR/$SERI $LINESER
    }

    [ $OTLSER ] && totf && {
        ui_print "  OpenType Layout ($OTLSER)"
        otl $OTLSER $TMPDIR/$SER
        [ $SER != $SERI ] && otl $OTLSER $TMPDIR/$SERI
    }
}

# San Francisco Mono
sfmono() {
    local up=$SFM it=$SFMI fa=${1:-$MO}
    fba; mkstya; fontinst

    [ "${LINEMS:=1.0}" != 1.0 ] && totf && {
        ui_print "  Line spacing ($LINEMS)"
        line $TMPDIR/$MS $LINEMS
        [ $MS != $MSI ] && line $TMPDIR/$MSI $LINEMS
    }

    [ $OTLMS ] && totf && {
        ui_print "  OpenType Layout ($OTLMS)"
        otl $OTLMS $TMPDIR/$MS
        [ $MS != $MSI ] && otl $OTLMS $TMPDIR/$MSI
    }
}

# Courier Prime
courier() {
    local up=$CP it=$CP fa=${1:-$SO}
    # ttc index font
    fba; mksty 7 4 3 3; fontinst r b

    [ "${LINESRM:=1.0}" != 1.0 ] && totf && {
        ui_print "  Line spacing ($LINESRM)"
        local i
        for i in ${CP%$Z}-$Re$X ${CP%$Z}-$It$X \
                 ${CP%$Z}-$Bo$X ${CP%$Z}-$Bo$It$X
        do
            line $TMPDIR/$SRMI $LINESRM
        done
    }
}

# emoji (NotoColorEmoji)
emoj() { cpf Emoji$X && font und-Zsye Emoji$X r; }

# Line height
# Change font ascender and descender proportionally instead of using Roboto's
# This is better in term of keeping font quality
# $1 font, $2 line
line() {
    [ $# -eq 2 ] && afdko 1 && {
        $TOOLS/pyftline $1 $2 || abort
        return
    }

    [ "$LINE" != 1.0 ] && totf || return
    ui_print "  Line spacing ($LINE)"

    local i
    # Line spacing for Uprights
    for i in $SF $SFI $SFR; do
        $TOOLS/pyftline $TMPDIR/$i $LINE || abort
    done
}

# Extract ttc to ttf
totf() {
    afdko 1 || return
    [ "$TOTF" ] && return

    # Extract ttc and rename extracted font files to match their true names
    # Roboto-Regular
    cp $FONTS/$RR $TMPDIR/${RR%?}c
    otc2otf $TMPDIR/${RR%?}c
    set .${SF%$X}-$Re $SF .${NY%$X}-$Re $NY .${SFM%$X}-$Li $SFM
    while [ $2 ]; do mv $TMPDIR/$1$X $TMPDIR/$2; shift 2; done

    # RobotoStatic
    cp $FONTS/$RS $TMPDIR/${RS%?}c
    otc2otf $TMPDIR/${RS%?}c
    set .${SF%$X}-$Re$It $SFI .${NY%$X}-$Re$It $NYI .${SFM%$X}-$Li$It $SFMI \
        ${SFR%$X}-$Re $SFR
    while [ $2 ]; do mv $TMPDIR/$1$X $TMPDIR/$2; shift 2; done

    # CourierPrime
    otf2otc -o $TMPDIR/$CP \
        $TMPDIR/${CP%$Z}-$Re$X $TMPDIR/${CP%$Z}-$It$X \
        $TMPDIR/${CP%$Z}-$Bo$X $TMPDIR/${CP%$Z}-$Bo$It$X &>$Null

    # Make it true to avoid extract them more than once
    TOTF=true
}

# Merge ttf to ttc
totc() {
    [ "$TOTF" = true ] || return 1

    # Roboto-Regular
    otf2otc -o $FONTS/$RR \
        $TMPDIR/$SF $TMPDIR/$RR $TMPDIR/$NY $TMPDIR/$SFM \
        $TMPDIR/${CP%$Z}-$Re$X $TMPDIR/${CP%$Z}-$Bo$X &>$Null

    # RobotoStatic
    otf2otc -o $FONTS/$RS \
        $TMPDIR/$SFI $TMPDIR/$SFR $TMPDIR/$NYI $TMPDIR/$SFMI \
        $TMPDIR/${CP%$Z}-$It$X $TMPDIR/${CP%$Z}-$Bo$It$X &>$Null
}

# Font alias
falias() {
    # alias to sans-serif by default
    local fa faq fae to=to=\"${2:-$SA}\"
    fa=${1:?} faq="/\"$fa\">/" fae="$faq,$FAE"
    # insert the <alias> tag
    xml "$faq i<alias name=\"$fa\" $to />"
    # delete old families, redirect others to new one
    xml "${fae}d"; xml "s|to=\"$fa\"|$to|"
}

# Replace the lock screen clock font (Pixel)
lsc(){
    $SANS && [ $GS = false -a $LSC != false ] && totf || return
    ui_print '+ Lock Screen Clock'
    
    local font=$PRDFONT/$GFC lsc=$TMPDIR/$SFR
    # Custom LSC
    [ $LSC = cust ] && {
        [ -f $OMFDIR/lsc$XY ] && {
            lsc=$OMFDIR/lsc$XY
            ui_print '  Custom'
        } || abort '! Font not found!'
    }

    # Font features
    [ "${LSCOTL:=`valof LSCOTL`}" ] && \
        pyftfeatfreeze -f $LSCOTL $lsc $TMPDIR/lsc$X &>$Null
    [ -f $TMPDIR/lsc$X ] || cp $lsc $TMPDIR/lsc$X

    # subset - only keep numbers and colon
    #pyftsubset $TMPDIR/lsc$X --unicodes=u30-3a \
    #    --passthrough-tables --output-file=$font
    cp $TMPDIR/lsc$X $font

    # Font style
    [ "${LSCSTY:=`valof LSCSTY`}" ] && \
        fonttools varLib.instancer -q -o $font $font \
        `echo $LSCSTY | sed 's|\([[:alpha:]]\) \([[:digit:]]\)|\1=\2|g'`

    # line spacing - has no effect on A16
    #[ ${LSCLINE:=`valof LSCLINE`} ] && $TOOLS/pyftline $font $LSCLINE
    # fix padding - no effect
    #$TOOLS/pyftlsc $font

    # Link GS Clock to GS Flex Clock
    ln -s $PrdFont/$GFC $PRDFONT/$GSC
}

# Make VF default weight 400. Set yMax to Roboto's
fontfix() {
    $FONTFIX || return
    local i f=$@
    [ "$f" ] || f=`echo $ORISS $ORISSI $ORISER $ORISERI $ORIMS $ORIMSI $ORISRM $ORISRMI | xargs -n1 | sort -u`
    [ "$f" ] && afdko || return

    [ $# -eq 0 ] && {
        for i in $f; do i=$FONTS/$i
            [ -f $i ] && $TOOLS/fontfix $i
        done
        return
    }
    for i in $f; do $TOOLS/fontfix $i; done
}

# Roboto spoofing
fontspoof() {
    # Alias to sans-serif
    falias source-sans-pro
    RBTF=`valof RBTF`
    ${RBTF:=false} || falias roboto-flex
    RBT=`valof RBT`
    ${RBT:=false} || falias roboto

    # LSC
    [ $PXL ] && lsc

    # Set SPOOF = false to disable
    SPOOF=`valof SPOOF`
    ${SPOOF:=true} || {
        totf
        local i
        for i in $SS $SSI $SFR $SER $SERI $MS $MSI $SRM; do
            cp $TMPDIR/$i $SYSFONT
        done

        [ $GS = false ] && {
            ln -sf $SysFont/$SS $PRDFONT/$GSR
            ln -sf $SysFont/$SS $PRDFONT/$GSF
        }

        return
    }

    # At least one of the main font families must be installed
    $SANS || $SERF || $MONO || $SRMO || return
    ui_print '+ Spoofing'

	totc
	cpf $RR $RS
	local id=" $ID"

    # The original Roboto index is 1
    xml "s|>$RR|$id\"1\"&|;s|>$RS|$id\"1\"&|"

    # Change font names to indexes
    $SANS && ( xml        "s|$SF|$RR|
                          s|$SFI|$RS|
                         s|>$SFR|$id\"1\">$RS|" )
    $SERF && xml         "s|>$NY|$id\"2\">$RR|
                         s|>$NYI|$id\"2\">$RS|"
    $MONO && xml        "s|>$SFM|$id\"3\">$RR|
                        s|>$SFMI|$id\"3\">$RS|"
    $SRMO && xml "s|$id\"0\">$CP|$id\"4\">$RR|
                  s|$id\"1\">$CP|$id\"4\">$RS|
                  s|$id\"2\">$CP|$id\"5\">$RR|
                  s|$id\"3\">$CP|$id\"5\">$RS|"
}

# Read value from the config
# $2 number of lines/values
valof() {
    sed -n "s|^$1[[:blank:]]*=[[:blank:]]*||p" $UCONF | \
        sed 's|[[:blank:]][[:blank:]]*| |g;s| $||' | \
        tail -${2:-1}
}

# Call valof(), search for a predefined instance
styof() {
    local s p
    # Check if the config file exists & the value is not empty
    [ -f $UCONF ] && [ "${s:=`valof $1`}" ] || return

    # Set optical sizes based on the global OPSZ
    # SF Italic does not have GRAD axis
    # fake GRAD by increase the wght and opsz
    # opsz of SF Italic equals OPSZ + 1
    local opsz=${opsz:-$OPSZ}
    p=$(sed -n "/^# $s$/{n;s|^# *||
        s|IOPSZ|`echo $opsz 1 + p | dc`|
        s|OPSZ|$opsz|
        p}" $UCONF | tail -1)

    # If misconfiguration, delete the config
    [ "$p" ] && echo $p || {
        echo $s | grep -Eq 'wdth|opsz|GRAD|wght|YAXS|SPAC' && \
        echo $s | sed "
            s|IOPSZ|`echo $opsz 1 + p | dc`|
            s|OPSZ|$opsz|" || \
            rm $UCONF
    }
}

# Read font styles config (VFs)
getsty() {
    local i
    for i in `up $FW`; do
        eval ${ups:?}$i=\"`styof $ups$i`\"
        [ $its ] && eval $its$i=\"`styof $its$i`\"
    done
}

# Load the config file
config() {
    local dconf dver uver
    # 3 hash signs is used for integrity check
    dconf=$MODPATH/config.cfg
    dver=`sed -n '/###/,$p' $dconf`
    uver=`sed -n '/###/,$p' $UCONF`
    [ "$uver" != "$dver" ] && {
        # backup old config and reset
        cp $UCONF $UCONF~; cp $dconf $UCONF
        ui_print '  Reset'
    }

    # Global options
    SANS=`valof SANS`       SERF=`valof SERF`     MONO=`valof MONO`        SRMO=`valof SRMO`
    GS=`valof GS`           LSC=`valof LSC`
    OTL=`valof OTL`         OTLTAG=`valof OTLTAG`
    OTLMS=`valof OTLMS`     OTLSER=`valof OTLSER` OTLSRM=`valof OTLSRM`
    LINE=`valof LINE`       FONTFIX=`valof FONTFIX`
    LINESER=`valof LINESER` LINEMS=`valof LINEMS` LINESRM=`valof LINESRM`
    OPSZ=`valof OPSZ`

    # Default values
    [ ${SANS:=true} ]; [ ${SERF:=true} ]; [ ${MONO:=true} ]; [ ${SRMO:=true} ]
    [ ${GS:=true}   ]; [ ${LSC:=true}  ]
    [ ${LINE:=1.0}  ]; [ ${FONTFIX:=false} ]

    # Main VFs
    SS=$SF SSI=$SFI SER=$NY SERI=$NYI
    MS=$SFM MSI=$SFMI SRM=$CP SRMI=$CP

    # Backup the original font names
    ORISS=$SS ORISSI=$SSI ORISER=$SER ORISERI=$SERI
    ORIMS=$MS ORIMSI=$MSI ORISRM=$SRM ORISRMI=$SRMI

	# Font styles

    # Dynamic optical sizes
    # change opsz based on font weight
    # use suffix a in the OPSZ to enable this
    OPSZs=false; case $OPSZ in *a) OPSZs=true OPSZ=${OPSZ%?} ;; esac
    local opsz i

    for i in $FW; do
		opsz=${OPSZ:?}
        $OPSZs && \
            case $i in
                t ) opsz=`echo $opsz 1 - p | dc` ;;
                el) opsz=`echo $opsz 1 - p | dc` ;;
                l ) opsz=`echo $opsz 0 - p | dc` ;;
                m ) opsz=`echo $opsz 0 + p | dc` ;;
                sb) opsz=`echo $opsz 1 + p | dc` ;;
                b ) opsz=`echo $opsz 1 + p | dc` ;;
                eb) opsz=`echo $opsz 2 + p | dc` ;;
                bl) opsz=`echo $opsz 2 + p | dc` ;;
            esac
			i=`up $i`

        # Main
        eval U$i=\"`styof U$i`\"
        eval I$i=\"`styof I$i`\"; eval [ \"\${I$i:=\$U$i}\" ]
        eval C$i=\"`styof C$i`\"; eval [ \"\${C$i:=\$U$i}\" ]
        eval M$i=\"`styof M$i`\"
        eval S$i=\"`styof S$i`\"

        # GS
        eval G$i=\"`styof G$i`\"    ; eval [ \"\${G$i:=\$U$i}\"    ]
        eval GI$i=\"`styof GI$i`\"  ; eval [ \"\${GI$i:=\$I$i}\"   ]
        eval GT$i=\"`styof GT$i`\"  ; eval [ \"\${GT$i:=\$U$i}\"   ]
        eval GTI$i=\"`styof GTI$i`\"; eval [ \"\${GTI$i:=\$I$i}\"  ]
        eval GF$i=\"`styof GF$i`\"  ; eval [ \"\${GF$i:=\$U$i}\"   ]
        eval GFI$i=\"`styof GFI$i`\"; eval [ \"\${GFI$i:=\$I$i}\" ]

        # Variable
        [ $i = R ] && {
            eval VDLR=\"`styof VDLR`\"; eval [ \"\${VDLR:=\$UR}\" ]
            eval VDMR=\"`styof VDMR`\"; eval [ \"\${VDMR:=\$UR}\" ]
            eval VDSR=\"`styof VDSR`\"; eval [ \"\${VDSR:=\$UR}\" ]
            eval VHLR=\"`styof VHLR`\"; eval [ \"\${VHLR:=\$UR}\" ]
            eval VHMR=\"`styof VHMR`\"; eval [ \"\${VHMR:=\$UR}\" ]
            eval VHSR=\"`styof VHSR`\"; eval [ \"\${VHSR:=\$UR}\" ]
            eval VTLR=\"`styof VTLR`\"; eval [ \"\${VTLR:=\$UR}\" ]
        }

        [ $i = M ] && {
            eval VTMM=\"`styof VTMM`\"; eval [ \"\${VTMM:=\$UM}\" ]
            eval VTSM=\"`styof VTSM`\"; eval [ \"\${VTSM:=\$UM}\" ]
            eval VLLM=\"`styof VLLM`\"; eval [ \"\${VLLM:=\$UM}\" ]
            eval VLMM=\"`styof VLMM`\"; eval [ \"\${VLMM:=\$UM}\" ]
            eval VLSM=\"`styof VLSM`\"; eval [ \"\${VLSM:=\$UM}\" ]
        }

        [ $i = R ] && {
            eval VBLR=\"`styof VBLR`\"; eval [ \"\${VBLR:=\$UR}\" ]
            eval VBMR=\"`styof VBMR`\"; eval [ \"\${VBMR:=\$UR}\" ]
            eval VBSR=\"`styof VBSR`\"; eval [ \"\${VBSR:=\$UR}\" ]
        }

        [ $i = M ] && {
            eval VDLEM=\"`styof VDLEM`\"; eval [ \"\${VDLEM:=\$UM}\" ]
            eval VDMEM=\"`styof VDMEM`\"; eval [ \"\${VDMEM:=\$UM}\" ]
            eval VDSEM=\"`styof VDSEM`\"; eval [ \"\${VDSEM:=\$UM}\" ]
            eval VHLEM=\"`styof VHLEM`\"; eval [ \"\${VHLEM:=\$UM}\" ]
            eval VHMEM=\"`styof VHMEM`\"; eval [ \"\${VHMEM:=\$UM}\" ]
            eval VHSEM=\"`styof VHSEM`\"; eval [ \"\${VHSEM:=\$UM}\" ]
            eval VTLEM=\"`styof VTLEM`\"; eval [ \"\${VTLEM:=\$UM}\" ]
        }

        [ $i = SB ] && {
            eval VTMESB=\"`styof VTMESB`\"; eval [ \"\${VTMESB:=\$USB}\" ]
            eval VTSESB=\"`styof VTSESB`\"; eval [ \"\${VTSESB:=\$USB}\" ]
            eval VLLESB=\"`styof VLLESB`\"; eval [ \"\${VLLESB:=\$USB}\" ]
            eval VLMESB=\"`styof VLMESB`\"; eval [ \"\${VLMESB:=\$USB}\" ]
            eval VLSESB=\"`styof VLSESB`\"; eval [ \"\${VLSESB:=\$USB}\" ]
        }

        [ $i = M ] && {
            eval VBLEM=\"`styof VBLEM`\"; eval [ \"\${VBLEM:=\$UM}\" ]
            eval VBMEM=\"`styof VBMEM`\"; eval [ \"\${VBMEM:=\$UM}\" ]
            eval VBSEM=\"`styof VBSEM`\"; eval [ \"\${VBSEM:=\$UM}\" ]
        }

        # Stop if the config file is removed (misconfiguration)
        [ ! -f $UCONF ] && config && break
    done
}

# These functions exist only for compatibility reason
# when execute font families vars, e.g. $SANS && ...
sans_serif() { true; }
serif() { true; }
serif_monospace() { true; }
monospace() { true; }

# Main installation process
install_font() {
    ui_print ' _____ _   _____     _____         _   '
    ui_print '|     | |_|     |_ _|   __|___ ___| |_ '
    ui_print '|  |  |   | | | | | |   __| . |   |  _|'
    ui_print '|_____|_|_|_|_|_|_  |__|  |___|_|_|_|  '
    ui_print '                |___|                  '

    ui_print '- Installing'
    ui_print '+ Preparing'
    prep
    ui_print '+ Configuring'
    config

    fontfix

    # sans-serif
    $SANS && {
        if [ $SANS = true ]; then
            ui_print '+ sans-serif'
            ui_print '  San Francisco Pro'
            sfui
        fi
    }

    # serif
    $SERF && {
        if [ $SERF = true ]; then
            ui_print '+ serif'
            ui_print '  New York'
            newyork
        fi
    }

    # monospace
    $MONO && {
        if [ $MONO = true ]; then
            ui_print '+ monospace'
            ui_print '  San Francisco Mono'
            sfmono
        fi
    }

    # serif-monospace
    $SRMO && {
        if [ $SRMO = true ]; then
            ui_print '+ serif-monospace'
            ui_print '  Courier Prime'
            courier
        fi
    }

    # emoji
    EMOJ=`valof EMOJ`
    [ -f $FONTS/Emoji$X ] && [ ${EMOJ:=true} ]
    ${EMOJ:=false} && {
        ui_print "• emoji"
        emoj
    }

    ui_print '+ ROM'
    rom

    ui_print '- Finalizing'
    fontspoof
    svc
    finish
}

# Remove unused files/folders, set permissions, unmount afdko
finish() {
    find $MODPATH/* -maxdepth 0 \
        ! -name 'system' \
        ! -name 'zygisk' \
        ! -name '*.rule' \
        ! -name '*.prop' \
        ! -name '*.sh' -exec rm -rf {} \;
    find $MODPATH/* -type d -delete &>$Null
    find $MODPATH/system -type f -exec chmod 644 {} \;
    find $MODPATH/system -type d -exec chmod 755 {} \;
    [ "$AFDKO" = true ] && { umount $TERMUX; rmdir -p $TERMUX; }
}

install_font

return

PAYLOAD:
