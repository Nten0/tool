#!/bin/bash

#Panagiotis Ntenezos
#AM: 5853

if [[ $# -eq 0 ]]; then #Otan i eisodos den periexei orismata emfanizetai mono to AM
    echo "5853"
else
    flag=0
    #anagnwrisi eisodou: vriskoume diladi poia entoli mas edwse o xristis
    while [[ "$1" != "" ]]; do
        case $1 in
            -f) 
                shift
                filename=$1
                ;;
            -id)
                shift
                id=$1
                flag=1
                ;;
            --firstnames)
                firstnames=$1
                flag=2
                ;;
            --lastnames)
                lastnames=$1
                flag=3
                ;;
            --born-since)
                shift
                dateA=$1
                if [[ $flag -eq 5 ]]; then #Stin periptwsi pou exei vrei to --born-until pio prin
                    flag=6
                else
                    flag=4 
                fi
                ;;
            --born-until)
                shift
                dateB=$1
                if [[ $flag -eq 4 ]]; then #Stin periptwsi pou exei vrei to --born-since pio prin
                    flag=6
                else
                    flag=5
                fi
                ;;    
            --browsers)
                browsers=$1
                flag=7
                ;;
            --edit)
                shift
                id=$1
                shift
                column=$1
                shift
                value=$1
                flag=8
                ;;
        esac 
        shift
    done
    
    #Me xrisi tis entolis flag exoume anagnwrisei poia entoli exei dothei stin eisodo opote pame stin analogi periptwsi
    #Se genikes grammes exoun xrisimopoihthei ta eksis
    # sed '/^#/ d' $filename pou afairei tis grammes me sxolia tou arxeiou eisodou
    # awk -F'|' pou dilwnei pws oriothetis pediou einai to sumvolo |
    # awk -v gia na perasoume mia metavliti tou bash mesa stin awk

    if [[ $flag -eq 0 ]]; then #Erwtima A: Emfanisi oloklirou tou arxeiou
        sed '/^#/ d' $filename | awk -F'|' '{ print $0 }' 
    elif [[ $flag -eq 1 ]]; then #Erwtima B: Otan i eisodos periexei -id
        sed '/^#/ d' $filename | awk -F'|' -v val=$id '{ if($1==val) print ($2 " " $3 " " $5) }'
    elif [[ $flag -eq 2 ]]; then #Erwtima C) Otan i eisodos periexei --firstnames
        sed '/^#/ d' $filename | sort -t$'|' -uk2,2 | awk -F'|' '{print $2}'
    elif [[ $flag -eq 3 ]]; then #Erwtima D) Otan i eisodos periexei --lastnames
        sed '/^#/ d' $filename | sort -t$'|' -uk3,3 | awk -F'|' '{print $3}' 
    elif [[ $flag -eq 4 ]]; then #Erwtima E) Otan i eisodos periexei mono --born-since
        sed '/^#/ d' $filename | awk -F'|' -v val=$dateA '{ if($5>=val) print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8 }'
    elif [[ $flag -eq 5 ]]; then #Erwtima E) Otan i eisodos periexei mono --born-until
        sed '/^#/ d' $filename | awk -F'|' -v val=$dateB '{ if($5<=val) print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8 }'     
    elif [[ $flag -eq 6 ]]; then #Erwtima E) Otan i eisodos periexei kai --born-since kai --born-until
        sed '/^#/ d' $filename | awk -F'|' -v valA=$dateA -v valB=$dateB '{ if($5>=valA && $5<=valB) print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8 }'
    elif [[ $flag -eq 7 ]]; then #Erwtima F) Otan i eisodos periexei --browsers
        sed '/^#/ d' $filename | awk -F'|' '{h[$8]++}; END { for(k in h) print k" "h[k] }' | sort -n    
    elif [[ $flag -eq 8 ]]; then #Erwtima G) Otan i eisodos periexei --edit
        if [[ $column -ge 2 && $column -le 8 ]]; then
            line=$(sed '/^#/ d' $filename | awk -F'|' -v v_id=$id '$1==v_id { print NR }' $filename) #arithmos grammis (pou vrisketai to id)
            tmp=$(sed '/^#/ d' $filename | awk -F'|' -v v_id=$id -v v_column=$column '$1==v_id { print $(v_column) }' $filename) #periexomeno stilis (column)
            if [[ $line != "" ]]; then
                sed "$line s/$tmp/$value/g" $filename > file #antikatastasi periexomenou kai apothikeusi se proswrino arxeio
                awk -F'|' '{ print $0 }' file > $filename #kai perasma pisw sto arxeio
            fi
        fi
    fi
fi
