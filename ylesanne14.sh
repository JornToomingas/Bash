#!/bin/bash

# Menüü valikud
PS3="Vali tegevus: "

select valik in "Uuenda paketid" "Paigalda apache2" "Eemalda apache2" "Välju"
do
    case "$REPLY" in

        1)
            # Uuendame pakette
            echo "Uuendan pakette..."

            if sudo apt update && sudo apt upgrade -y
            then
                echo "Õnnestus: paketid on uuendatud."
            else
                echo "Ebaõnnestus: pakettide uuendamine."
            fi
            ;;

        2)
            # Kontrollime enne paigaldamist, kas apache2 on juba olemas
            if dpkg -s apache2 > /dev/null 2>&1
            then
                echo "apache2 on juba paigaldatud."
            else
                echo "Paigaldan apache2..."

                # Paigaldame apache2 vaikimisi yes-valikuga
                if sudo apt install apache2 -y
                then
                    # Käivitame apache2 teenuse
                    if sudo systemctl start apache2
                    then
                        echo "Õnnestus: apache2 paigaldati ja käivitati."
                    else
                        echo "Ebaõnnestus: apache2 käivitamine."
                    fi
                else
                    echo "Ebaõnnestus: apache2 paigaldamine."
                fi
            fi
            ;;

        3)
            # Kontrollime enne eemaldamist, kas apache2 on paigaldatud
            if dpkg -s apache2 > /dev/null 2>&1
            then
                echo "Peatan apache2 teenuse..."

                # Peatame apache2 teenuse
                sudo systemctl stop apache2

                echo "Eemaldan apache2..."

                # Eemaldame apache2 ja kasutamata paketid
                if sudo apt purge apache2 -y && sudo apt autoremove -y
                then
                    echo "Õnnestus: apache2 eemaldati."
                else
                    echo "Ebaõnnestus: apache2 eemaldamine."
                fi
            else
                echo "apache2 ei ole paigaldatud."
            fi
            ;;

        4)
            # Väljumise valik
            echo "Väljun programmist."
            exit 0
            ;;

        *)
            # Vigase valiku teavitus
            echo "Vigane valik. Palun vali number 1, 2, 3 või 4."
            ;;
    esac
done
