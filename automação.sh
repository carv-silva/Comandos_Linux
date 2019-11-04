#!/usr/bin/env bash
# /bin/bash é o modo errado, já que nem sempre o bash estará disponível lá.

# Priori: Nunca editar isso no windows. Convenção Linux: \n; Windows: \r\n.
# Executar através do: source/não do bash

#======================#
# Colors
Br="\033[1;37m"  # Cinza negrito
Cz="\033[0;37m"  # Cinza normal
Rd="\033[1;31m"  # Vermelho
Vd="\033[1;32m"  # Verde
Cy="\033[0;36m"  # Verde água
Fm="\e[0m"  # None
#======================#

#======================#
check_for_package(){
	if dpkg-query -s "$1" 1>/dev/null 2>&1; then
        return 0  # instalado
    else
    	if apt-cache show "$1" 1>/dev/null 2>&1; then
            return 1  # não instalado, porém disponível no registro de pacote
        else
            return 2  # não instalado/disponível
        fi
    fi
}
#======================#

#======================#
# É usado globalmente
line='------------------------------------------'
install_packages(){
	echo ""
    # $@: Truque para "desempacotar" todos os valores recebidos, tipo PY
    for package in "$@"; do
    	if check_for_package "$package"; then
            printf "${Rd}%s${Fm} ${Br}%s [INSTALADO]${Fm}\n" $package "${line:${#package}}" # ${line:${#package}}: Truque bash para simular efeito "sumário"
        else
        	if test "$?" -eq 1; then
        		echo -e "${Br}Iniciando instalação do $package...${Fm}"
        		take_a_break
        		sudo apt install -y $package

        	fi
        fi
    done
    echo ""
}
#======================#

#======================#
take_a_break() {
    # Não precisa do "s", mas nas conferências eles solicitam
    sleep 3s
}
#======================#

#======================#
valida_ssh(){
    if [ -e ~/.ssh/id_rsa.pub ]; then
        echo -e "\n${Br}Seu PC já tem SSH keys, pulando etapa...${Fm}"
        take_a_break
    else
        ssh-keygen
    fi
}
#======================#

#======================#
checar_source() {
    if [[ ${BASH_SOURCE[0]} -ef "$0" ]]; then
        echo ""
        echo -e ${Rd}"PARA EXECUTAR ESSE PROGRAMA, RODE: source automação.sh"${Fm}
        echo ""
        exit
        clear
    else
        clear
        echo ""
        echo -e ${Rd}"===${Fm}${Br}STARTANDO O PROGRAMA AGUARDE!${Fm}${Rd}==="${Fm}
        sleep 3s
    fi
}
#======================#

#======================#
retorna_menu() {
	echo ""
	echo -e ${Rd}"RETORNANDO..."${Fm}
	take_a_break
	clear
}
#======================#

#======================#
encerra_menu() {
	echo ""
	echo -e ${Rd}"SAINDO EM 3 SEGUNDOS..."${Fm}
	echo -e ${Cy}"OBRIGADO POR USAR O AUTOMATION..."${Fm}
	take_a_break
	clear
	# exit
}
#======================#

#======================#
atualizacao() {
    sudo apt update && sudo apt upgrade -y
}
#======================#

#======================#
OPCAO() {
	case $digito in

		1 | 01)

		echo -e "${Br}A última atualização de algum pacote ocorreu em...${Fm}"
		grep Start-Date /var/log/apt/history.log | tail -1
		echo -e "${Br}Iniciando atualização...${Fm}"
		take_a_break; atualizacao ;;

		2 | 02)

		install_packages tree vlc vim unrar soundconverter easytag dos2unix ;;

		3 | 03)

		install_packages heroku; heroku login ;;

		4 | 04)

		read -p $'\n\033[1;37mApenas reiniciar? [s/n] \033[m' resposta

		for (( ; ; )); do

    		if [[ "${resposta}" = @(s|S|y|Y) ]] ; then
	    		echo -e "${Br}Reiniciando...${Fm}"
	    		sudo service minidlna restart && sudo service minidlna force-reload
	    		break

    		elif [[ "${resposta}" = @(n|N) ]] ; then
    			install_packages minidlna
				# Checando se já está configurado
				if grep -Fxq "friendly_name=DLNA" /etc/minidlna.conf ; then
					echo -e "${Br}Já está configurado, abortando...${Fm}"
					take_a_break
                    break

				else
		            sudo sed -i "s|#inotify=yes|inotify=yes|g" /etc/minidlna.conf  # automatic discover new files
		            sudo sed -i "s|#friendly_name=|friendly_name=DLNA|g" /etc/minidlna.conf  # server_name
		            sudo sed -i "s|#db_dir=/var/cache/minidlna|db_dir=...|g" /etc/minidlna.conf
		            sudo sed -i "s|#log_dir=/var/log|log_dir=...|g" /etc/minidlna.conf
		            sudo sed -i "s|#user=minidlna|user=root|g" /etc/minidlna.conf
		            sudo sed -i "s|media_dir=/var/lib/minidlna|media_dir=/home/$USER/Vídeos/|g" /etc/minidlna.conf
		            sudo sed -i 's|#USER="minidlna"|USER="root"|g' /etc/default/minidlna
		            sudo service minidlna restart && sudo service minidlna force-reload
		            break

		        fi
		    else
                echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\n\n${Br}DESEJA APENAS REINICIAR?${Fm}\n${Br}[S/N] R: ${Fm}"
                read resposta

        	fi
        done ;;

        5 | 05)  # Git

		echo -e "${Br}Efetue login no GITHUB e remova sua chave pública (caso tenha).${Fm}"
        take_a_break

        read -p $'\033[1;37mJá removeu? [s/n] \033[m' resposta

        for (( ; ; )); do
            if [[ "${resposta}" = @(s|S|y|Y) ]] ; then
                break

            elif [[ "${resposta}" = @(N|n) ]] ; then
                echo -e "${Br}Então remova ¯\_(ツ)_/¯${Fm}"
                take_a_break
                read -p $'\033[1;37mಠ_ಠ [s/n] \033[m' resposta

            else
                echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\n\n${Br}JÁ REMOVEU?${Fm}\n${Br}[S/N] R: ${Fm}"
                read resposta

            fi

        done

        install_packages git

        # Valida constantes
        if [ -e ~/.gitconfig ]; then
            cat ~/.gitconfig

            for (( ; ; )); do
                read -p $'\n\033[1;37mSeus dados aparecem acima?! [S/n] \033[m' resposta

                if [[ "${resposta}" = @(s|S|y|Y) ]] ; then
                    echo -e "${Br}OK, não precisaremos dessa configuração${Fm}"
                    take_a_break
                    break

                elif [[ "${resposta}" = @(n|N) ]] ; then
                    read -p $'\n\033[1;37mInforme seu e-mail: \033[m' email
                    read -p $'\033[1;37mNome: \033[m' nome
                    # Configurando dados
                    git config --global user.email "$email"
                    git config --global user.name "$nome"
                    echo -e "${Br}Seus dados incluídos foram...${Fm}"
                    # git config --list
                    cat ~/.gitconfig
                    take_a_break
                    break

                else
                    echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\n\n${Br}APARECEM ACIMA?${Fm}\n${Br}[S/N] R: ${Fm}"
                    read resposta

                fi
            done

        else
            echo -e "\n${Br}Vamos configurar os dados de quem usará o GIT${Fm}"
            take_a_break
            # Recolhendo dados
            read -p $'\033[1;37mInforme seu e-mail: \033[m' email
            read -p $'\033[1;37mNome: \033[m' nome
            # Configurando dados
            git config --global user.email "$email"
            git config --global user.name "$nome"
            echo -e "${Br}Seus dados incluídos foram...${Fm}"
            # git config --list
            cat ~/.gitconfig
            take_a_break

        fi

        valida_ssh

		# Valida referência
        if [ -e ~/.ssh/config ]; then
            cat ~/.ssh/config

            for (( ; ; )); do
                read -p $'\n\033[1;37mhost.github configurado?! [S/n] \033[m' resposta

               	if [[ "${resposta}" = @(s|S|y|Y) ]] ; then
                    echo -e "${Br}OK, pulando etapa...${Fm}"
                    take_a_break
                    break

                elif [[ "${resposta}" = @(n|N) ]]; then
                    echo "Host github.com
Hostname ssh.github.com
Port 443" > ~/.ssh/config  # If file exists but not configured

                    break
                else
                    echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\n\n${Br}HOST.GITHUB CONFIGURADO?${Fm}\n${Br}[S/N] R: ${Fm}"
                    read resposta

                fi
            done
        else
            echo -e "\n${Br}Configurando...${Fm}"
            take_a_break
            echo "Host github.com
Hostname ssh.github.com
Port 443" > ~/.ssh/config

		fi

        echo -e "\n${Br}Enviando as chaves SSH pro github${Fm}"

        for (( ; ; )); do
            read -p $'\033[1;37mInforme seu usuário do github: \033[m' user
            read -p $'\033[1;37mSenha: \033[m' password

            envia_ssh=`curl -i -s -u "$user:$password" --data '{"title":"Aceita eu","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' https://api.github.com/user/keys | grep "Status:" | cut -c9-`

            if [[ $(echo "$envia_ssh") =~ "401 Unauthorized" ]]; then
                echo -e "\n${Rd}LOGIN INCORRETO, TENTE NOVAMENTE!!!${Fm}\n"
                take_a_break
            else
                echo -e "\n${Br}Conexão com GITHUB estabelecida!${Fm}\n"
                take_a_break
                break
            fi
        done

        install_packages git-cola  # Não vai em cima porque depende da config .gitconfig

        current="$(git --version)"
        required="2.23.0"

        if [ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" = "$required" ]; then
            echo -e "\n${Br}Não há necessidade de atualizar seu GIT${Fm}"
            take_a_break

        else
            sudo add-apt-repository ppa:git-core/ppa
            atualizacao
            git --version
            take_a_break

        fi

        echo -e "\n${Br}Checando se o github aceitará nosso host${Fm}"
        ssh -T git@github.com ;;  # Verificando conexão

        6 | 06)

        current="$(python --version)"
        required="3.5.0"

        if [ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" = "$required" ]; then
            echo -e "${Br}Não há necessidade de atualizar.${Fm}"
            take_a_break
        else
            echo -e "\n${Br}Sua versão é < que 3.5, atualizando...${Fm}"
            take_a_break

            install_packages wget zlib1g-dev libreadline-dev libsqlite3-dev curl llvm libncurses5-dev libbz2-dev libssl-dev libffi-dev  # Dependências PYenv

            if [ -d ~/.pyenv ]; then
                echo -e "\n${Br}O PYenv já está instalado...${Fm}"
                take_a_break

            else
                echo -e "\n${Br}Instalando o PYenv${Fm}"
                take_a_break
                sudo curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

        	fi

            if grep -Fxq 'export PATH="$HOME/.pyenv/bin:$PATH"' ~/.bashrc; then
                echo -e "\n${Br}As constantes já foram atribuídas...${Fm}"
                take_a_break

            else
                echo -e "${Br}Atribuindo as variáveis ao bash${Fm}"
                echo '
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init - --no-rehash)"
eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

            fi

            source ~/.bashrc
            # Available: pyenv install -l
            # Installed: pyenv versions
            pyenv install 3.7.3
            # Last release, date: 21/05/2019
            pyenv global 3.7.3

        fi ;;

        7 | 07)

 		install_packages python-pip python-dev build-essential
        pip install -U pip ;;

        8 | 08) # Sublime Text

 		if [ "$(dpkg -l | awk '/sublime-text/ {print }'|wc -l)" -ge 1 ]; then
            module='sublime-text-3'
            printf "\n${Rd}%s${Fm} ${Br}%s [INSTALADO]${Fm}\n\n" $module "${line:${#module}}"

        else
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

            # Instalando dependências
            install_packages apt-transport-https
            # Adicionando a referência ao sublime na lista de repositórios
            echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

            atualizacao
            install_packages sublime-text

        fi

        # Não sai do loop enquanto o sublime não cria os arquivos padrão
        for (( ; ; )); do
            if [[ -d ~/.config/sublime-text-3 ]]; then

                echo -e "${Br}Diretório padrão criado, configurando..."
                take_a_break
                # hexed.it, pegar a posição e converter pra decimal (seek).
                cd ~/.config/sublime-text-3/
                printf '\00\00\00' | dd of=sublime_text bs=1 seek=158612 count=3 conv=notrunc status=none
                # Removendo vários "sublimes" no menu do mint
                sudo rm -rf ~/.local/share/recently-used.xbel

                echo "----- BEGIN LICENSE -----
TwitterInc
200 User License
EA7E-890007
1D77F72E 390CDD93 4DCBA022 FAF60790
61AA12C0 A37081C5 D0316412 4584D136
94D7F7D4 95BC8C1C 527DA828 560BB037
D1EDDD8C AE7B379F 50C9D69D B35179EF
2FE898C4 8E4277A8 555CE714 E1FB0E43
D5D52613 C3D12E98 BC49967F 7652EED2
9D2D2E61 67610860 6D338B72 5CF95C69
E36B85CC 84991F19 7575D828 470A92AB
------ END LICENSE ------" > ~/.config/sublime-text-3/Local/License.sublime_license

                # Ativando Package Control
                sudo wget -q 'https://packagecontrol.io/Package%20Control.sublime-package' ~/.config/sublime-text-3/Installed Packages

                # Pré-instalando os pacotes que utilizo
                echo '{
    "installed_packages":
    [
        "Package Control",
        "Anaconda",
        "Djaneiro",
        "Restart",
        "SublimeREPL",
    ]
}' > ~/.config/sublime-text-3/Packages/User/Package\ Control.sublime-settings

                for (( ; ; )); do
                    # Se instalou um pacote, instalou o restante também, então...
                    if [[ -f ~/.config/sublime-text-3/Installed\ Packages/Djaneiro.sublime-package ]]; then
                        # Chave/valor modificados
                        sudo sed -i 's|"python"|"/usr/bin/python3.6"|g' ~/.config/sublime-text-3/Packages/Anaconda/Anaconda.sublime-settings
                        sudo sed -i 's|"swallow_startup_errors": false|"swallow_startup_errors": true|g' ~/.config/sublime-text-3/Packages/Anaconda/Anaconda.sublime-settings
                        # Setar Python 3 no SublimeREPL
                        sudo wget 'https://gist.githubusercontent.com/rafaelribeiroo/4ef74bab4462bf62b1d87f57feaa728d/raw/a5680456fdd19d7a27a5e4371cf31dc2b73375c7/Main.sublime-menu' -O ~/.config/sublime-text-3/Packages/SublimeREPL/config/Python/Main.sublime-menu
                        # Remover o autocomplete no interpreter
                        sudo sed -i 's|"auto_complete": true|"auto_complete": false|g' ~/.config/sublime-text-3/Packages/SublimeREPL/SublimeREPL.sublime-settings
                        # Key Binding pro PY: Ctrl + P
                        echo '[
    { "keys": ["ctrl+p"], "command": "run_existing_window_command", "args":
    {
        "id": "repl_python_run",
        "file": "config/Python/Main.sublime-menu"
    }}
]' > ~/.config/sublime-text-3/Packages/User/Default\ \(Linux\).sublime-keymap

                        # Acrescentar "régua" no editor
                        echo '{
    // default value is []
    "rulers": [79],

    "word_wrap": false,

    "wrap_width": 80,

    "tab_size": 4,
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true,
    "ensure_newline_at_eof_on_save": true,

    "font_size": 12,
}' > ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings

                        # Reutilizar mesma tab para interpretar
                        sudo wget --no-check-certificate 'https://gist.githubusercontent.com/rafaelribeiroo/eba238cf22ee70270a9eb6f220f4d893/raw/5a0003726f167894574373ff2e0f9335028ba83c/Main.sublime-menu' -O ~/.config/sublime-text-3/Packages/SublimeREPL/config/Python/Main.sublime-menu
                        # Reutilizar mesma tab para interpretar: Continuação
                        sudo sed -i 's|if view.id() == view_id|if view.name() == view_id|g' ~/.config/sublime-text-3/Packages/SublimeREPL/sublimerepl.py
                        # Reutilizar mesma tab para interpretar: Continuação
                        sudo sed -i "s|found = view|found = view\n                  window.focus_view(found)|g" ~/.config/sublime-text-3/Packages/SublimeREPL/sublimerepl.py

                        # As alterações passarem a valer
                        nohup subl &!
                        take_a_break; take_a_break
                        sudo pkill subl*

                        break

                    else
                        echo -e "\n${Br}Acessaremos o sublime novamente para ele instalar os pacotes pré-instalados.${Fm}"
                        nohup subl &!
                        for contador in {1..10..1}; do
                            take_a_break
                        done
                        sudo pkill subl*
                    fi
                done

                break

            else
                echo -e "\n${Br}Acessaremos o sublime para ele criar o diretório padrão.${Fm}"
                take_a_break
                # O sublime cria os diretórios padrão quando executado pela 1a vez
                nohup subl &!
                take_a_break; take_a_break
                sudo pkill subl
            fi
        done ;;

        9 | 09)

		install_packages tmate; valida_ssh ;;

        10)  # Feh

 		install_packages feh
        sudo mkdir -p ~/.icons/

        sudo wget --no-check-certificate 'https://drive.google.com/open?id=10xTuHMQLsYEIr8bYPy4rr6HOBTmcRFmY' -O ~/.icons/l.jpg
        sudo wget --no-check-certificate 'https://drive.google.com/open?id=1cfVKHnXsZtvkdDspBgBMtBxbJ2JVwCpu' -O ~/.icons/r.jpg
        feh --bg-scale ~/.icons/l.jpg ~/.icons/r.jpg

        echo "[Desktop Entry]
Name=Feh
Type=Application
Exec=/home/$USER/.fehbg
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
Name[pt_BR]=background_imgs
Comment[pt_BR]=Wallpaper único para cada monitor" > ~/.config/autostart/jpg.desktop ;;

		11)

        install_packages libxss1 libappindicator1 libindicator7

        cd ~/Downloads/
        if [ -f "google-chrome*.deb" ]; then
            echo -e "${Br}Arquivo já baixado, instalando...${Fm}"
            take_a_break
        else
            sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        fi

        sudo dpkg -i google-chrome*.deb
        sudo rm -rf google-chrome*.deb ;;

        12) # PostgreSQL

        if grep -Fxq 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' /etc/apt/sources.list.d/pgdg.list; then
            echo -e "${Br}Referência ao Postgres OK!${Fm}"
            take_a_break

        else
            sudo chown $USER:$USER -R /etc/apt/sources.list.d/
            echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list

        fi

        # Não é necessário verificar. Mesmo existindo, ele atualizará.
        sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

        atualizacao; install_packages postgresql-10 postgresql-contrib-9.6 libpq-dev pgadmin4

        # Habilitando para acessar o post
        sudo sed -i "s|#listen_addresses|listen_addresses|g" /etc/postgresql/10/main/postgresql.conf
        # Altera criptografia pra md5
        sudo sed -i "s|local   all             postgres                                peer|local   all             postgres                                md5|g" /etc/postgresql/10/main/pg_hba.conf

        read -p $'\033[1;37mDeseja criar um usuário? [s/n] \033[m' resposta
        for (( ; ; )); do
            if [[ "${resposta}" = @(s|S|y|Y) ]] ; then
                read -p $'\033[1;37mInforme a senha: \033[m' password

                sudo -u postgres psql -c "CREATE USER $USER WITH ENCRYPTED PASSWORD '$password'"
                sudo -u postgres psql -c "ALTER ROLE $USER SET client_encoding TO 'utf8'"
                sudo -u postgres psql -c "ALTER ROLE $USER SET default_transaction_isolation TO 'read committed'"
                sudo -u postgres psql -c "ALTER ROLE $USER SET timezone TO 'America/Sao_Paulo'"

            elif [[ "${resposta}" = @(N|n) ]] ; then
                echo -e "${Br}Ok, voltando ao menu${Fm}"
                take_a_break; retorna_menu; break
            else
                echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\n\n${Br}DESEJA CRIAR UM USUÁRIO?${Fm}\n${Br}[S/N] R: ${Fm}"
                read resposta
            fi
        done

        status=`systemctl is-active postgresql.service`
        if [[ ${status} == 'active' ]]; then  # Se o Postgres estiver rodando
            sudo service postgresql restart
        else
            sudo service postgresql start
        fi ;;

        13)

        if [ -d /workspace ]; then
            echo -e "${Br}Diretório OK${Fm}"
            take_a_break
        else
            sudo mkdir -p /workspace/
        fi

        sudo chown $USER:$USER -R /workspace/ ;;

        14)
        if test -f "~/Downloads/Deezloader_Remix*"; then
            echo -e "${Br}Já existe.${Fm}"
        else
            sudo wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1Uh4AwOtLftYmcnhynBa2UdM3YgnKwprT' -O ~/Downloads/Deezloader_Remix_4.2.2-x86_64.AppImage
        fi

        sudo chmod +x ~/Downloads/Deezloader_Remix_4.2.2-x86_64.AppImage ;;

        15)
        if [ "$(dpkg -l | awk '/libreoffice*/ {print }'|wc -l)" -ge 1 ]; then
            sudo apt remove --purge libreoffice*
        else
            echo -e "${Br}Libreoffice desinstalado.${Fm}"
            take_a_break
        fi

        echo -e "\n${Br}Iniciando remoção de dependências inúteis.${Fm}"
        take_a_break; sudo apt autoremove -y; sudo apt autoclean -y ;;

        16)

		install_packages nodejs npm

        module='gtop'
        if [ `npm list -g | grep -c $module` -eq 0 ]; then
            sudo npm install -g $module
        else
            printf "${Rd}%s${Fm} ${Br}%s [INSTALADO]${Fm}\n" $module "${line:${#module}}"
        fi

        echo 'export npm_config_loglevel=silent' >> ~/.zshrc

        ;;

        17)

		install_packages zsh

        if [ -d ~/.oh-my-zsh ]; then
            module='oh-my-zsh'
            printf "${Rd}%s${Fm} ${Br}%s [INSTALADO]${Fm}\n" $module "${line:${#module}}"
            take_a_break
        else
            echo -e "${Br}Instalando o oh-my-zsh${Fm}"
            take_a_break
            sudo sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
        fi

        cd ~/Downloads/

        if [ -f ~/.fonts/PowerlineSymbols.otf ]; then
            echo -e "\n${Br}Fonte OK, abortando...${Fm}"
            take_a_break
        else
            sudo wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf

            if [ -d ~/.fonts/ ]; then
                echo -e "${Br}Diretório OK${Fm}"
                take_a_break
            else
                sudo mkdir -p ~/.fonts/
            fi

            sudo chown $USER:$USER -R ~/.fonts/
            sudo mv PowerlineSymbols.otf ~/.fonts/
            sudo fc-cache -vf ~/.fonts/  # Atualiza o cache de fontes

        fi

        if [ -f ~/.config/fontconfig/conf.d/10-powerline-symbols.conf ]; then
            echo -e "${Br}Fonte OK, abortando...${Fm}"
            take_a_break
        else
            sudo wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

            if [ -d ~/.config/fontconfig/conf.d ]; then
                echo -e "${Br}Diretório OK${Fm}"
                take_a_break
            else
                sudo mkdir -p ~/.config/fontconfig/conf.d
            fi

            sudo chown $USER:$USER -R ~/.config/fontconfig/conf.d
            sudo mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

        fi

        # Alteração de tema
        sudo sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="agnoster"|g' ~/.zshrc
        # Incluindo pacotes adicionais
        sudo sed -i 's|plugins=(git)|plugins=(git autopep8 django docker github pep8 python pyenv pip virtualenv)|g' ~/.zshrc
        # Removendo user@hostname$
        if grep -Fxq 'DEFAULT_USER=`whoami`' ~/.zshrc; then
            echo -e "\n${Br}DEFAULT_USER OK...${Fm}"
            take_a_break
        else
            echo -e "${Br}Atribuindo a variável...${Fm}"
            take_a_break
            echo '
DEFAULT_USER=`whoami`' >> ~/.zshrc
        fi

        if [[ $(echo $SHELL) == "/bin/zsh" ]] ; then
            echo -e "${Br}O shell atual já é o ZSH!${Fm}"
            take_a_break
        else
            sudo chsh -s /bin/zsh

            echo -e "${Br}Para tornar o ZSH padrão, precisamos reiniciar"
            take_a_break

            read -p $'\033[1;37mPodemos reiniciar? [s/n] \033[m' resposta
            for (( ; ; )); do
                if [[ "${resposta}" = @(s|S|y|Y) ]] ; then
                    sudo reboot -f

                elif [[ "${resposta}" = @(N|n) ]] ; then
                    echo -e "${Br}Ok, voltando ao menu!${Fm}"
                    take_a_break; retorna_menu; break

                else
                    echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\n\n${Br}PODEMOS REINICIAR?${Fm}\n${Br}[S/N] R: ${Fm}"
                    read resposta
                fi
            done
        fi

        ;;

        18)

        read -p $'\033[1;37mQuantos dispositivos deseja ocultar, '"${USER}"$'? \033[m' QNTDE

        sudo chown $USER:$USER -R /etc/udev/rules.d/

        for contador in `seq $QNTDE`; do
            echo 'ENV{ID_FS_UUID}=="UUID_'"$contador"'",ENV{UDISKS_IGNORE}="1"' >> /etc/udev/rules.d/99-hide-disks.rules
        done

        echo -e "\n${Br}Informe a referência do dispositivo (sda)${Fm}"

        for contador in `seq $QNTDE`; do
            read -p $'\033[1;37m'"${contador}"$'ª ref.: \033[m' disco
            sudo sed -i "s|UUID_$contador|$(blkid -s UUID -o value /dev/${disco})|g" /etc/udev/rules.d/99-hide-disks.rules
        done

        # Configurações necessárias para fixar alterações sem reiniciar
        sudo udevadm control --reload-rules; sudo udevadm trigger ;;

        19)

        install_packages docky dconf-editor gconf-editor; nohup docky &!

        sudo chown $USER:$USER -R ~/.config/autostart/
        echo '[Desktop Entry]
Name=Docky
Type=Application
Exec=docky
Terminal=false
Icon=docky
Comment=The finest dock no money can buy.
Comment[pt]=A melhor doca que nenhum dinheiro pode comprar.
Comment[pt_BR]=O melhor dock que dinheiro algum pode comprar.
NoDisplay=false
Categories=Utility;
Hidden=false' > ~/.config/autostart/docky.desktop

        sudo gconftool-2 --type Boolean --set /apps/docky-2/Docky/Items/DockyItem/ShowDockyItem False  # # Removendo o ícone do docky

        active=$(gconftool-2 --get /apps/docky-2/Docky/DockController/ActiveDocks | sed 's/.*\[\([^]]*\)\].*/\1/g')  # Docky ativo
        sudo gconftool --type string --set /apps/docky-2/Docky/Interface/DockPreferences/$active/IconSize '50'
        sudo gconftool --type list --list-type string --set /apps/docky-2/Docky/Interface/DockPreferences/$active/Plugins '[Clippy,Clock]'
        sudo gconftool --type string --set /apps/docky-2/Docky/Interface/DockPreferences/$active/Autohide 'UniversalIntellihide'  # Configs pro docky ficar sobreposto a qualquer janela
        sudo gconftool --type bool --set /apps/docky-2/Docky/Interface/DockPreferences/$active/FadeOnHide True
        sudo gconftool --type int --set /apps/docky-2/Docky/Interface/DockPreferences/$active/FadeOpacity 1
        sudo gconftool --type string --set /apps/docky-2/Docky/Services/ThemeService/Theme 'Smoke'  # Themes
        sudo gconftool --type bool --set /apps/docky-2/Docky/Interface/DockPreferences/$active/ThreeDimensional True
        sudo gconftool --type bool --set /apps/docky-2/Docky/Interface/DockPreferences/$active/ZoomEnabled True
        sudo gconftool --type int --set /apps/docky-2/Docky/Interface/DockPreferences/$active/ZoomPercent 2
        sudo gconftool --type string --set /apps/docky-2/Docky/Interface/DockPreferences/$active/Position 'Bottom'

        sudo dconf write /org/cinnamon/panels-enabled "['1:0:top']"
        sudo dconf write /org/cinnamon/panels-height "['1:21']"
        sudo dconf write /org/cinnamon/enabled-applets "['panel1:left:0:menu@cinnamon.org:0', 'panel1:right:8:network@cinnamon.org:9', 'panel1:right:7:sound@cinnamon.org:10', 'panel1:right:5:expo@cinnamon.org:13', 'panel1:right:4:keyboard@cinnamon.org:21', 'panel1:right:3:keyboard@cinnamon.org:22', 'panel1:right:2:show-desktop@cinnamon.org:23', 'panel1:right:1:power@cinnamon.org:24', 'panel1:right:0:blueberry@cinnamon.org:25', 'panel1:right:9:user@cinnamon.org:26']"

        sudo chown $USER:$USER -R /usr/share/icons/hicolor/scalable/apps/
        sudo rm -rf /usr/share/icons/hicolor/scalable/apps/linuxmint-logo-5.svg
        sudo wget --no-check-certificate 'https://drive.google.com/open?id=1WMlTZp3VaPSfep0ZsdB3g2jioaXj8gcl' -O /usr/share/icons/hicolor/scalable/apps/linuxmint-logo-5.svg
        sudo dconf write /com/linuxmint/mintmenu/applet-icon "'/usr/share/icons/hicolor/scalable/apps/linuxmint-logo-5.svg'"

        sudo wget --no-check-certificate 'https://drive.google.com/open?id=1UNLgXqDAKKUZtFohePaW1rMteWYYwiFD' -O ~/.icons/macOS.jpg  # Change wallpaper
        sudo dconf write /org/cinnamon/desktop/background/picture-uri "'file:///home/$user/.icons/macOS.jpg'"

        sudo dconf write /org/cinnamon/desktop/wm/preferences/button-layout "'close,minimize,maximize:'"

        cd ~/Downloads
        git clone https://github.com/fusion809/macOS-Arc-White.git
        git clone https://github.com/keeferrourke/la-capitaine-icon-theme.git
        sudo mv macOS* la* ~/.themes/

        # Na interface UI, localizará em temas (iniciar)
        dconf write /org/cinnamon/desktop/wm/preferences/theme "'Mint-Y'"  # Bordas da janela
        dconf write /org/cinnamon/desktop/interface/icon-theme "'la-capitaine-icon-theme-master'"  # Ícones
        dconf write /org/cinnamon/theme/name 'macOS-Arc-White-master'  # Área de trabalho
        dconf write /org/cinnamon/desktop/interface/gtk-theme "'macOS-Arc-White-master'"  # Controles
        dconf write /org/cinnamon/desktop/interface/cursor-theme "'DMZ-White'"  # Ponteiro do mouse

        install_packages synapse nautilus

        sudo xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search ;;  # Nautilus instead nemo

        20)

        install_packages powerline

        if [ -d /usr/local/bin/powerline ]; then
            echo -e "${Br}Diretório OK${Fm}"
            take_a_break
        else
            sudo mkdir -p /usr/local/bin/powerline
        fi

        if [ -w /tmp/myfile.txt ]; then
             echo -e "${Br}Permissões concedidas!${Fm}"
        else
             sudo chown $USER:$USER -R /usr/local/bin/powerline
        fi

        git clone https://github.com/powerline/powerline.git /usr/local/bin/powerline/

        if [ -f ~/.fonts/PowerlineSymbols.otf ]; then
            echo -e "\n${Br}Fonte OK, abortando...${Fm}"
            take_a_break
        else
            sudo wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf

            if [ -d ~/.fonts/ ]; then
                echo -e "${Br}Diretório OK${Fm}"
                take_a_break
            else
                sudo mkdir -p ~/.fonts/
            fi

            sudo chown $USER:$USER -R ~/.fonts/
            sudo mv PowerlineSymbols.otf ~/.fonts/
            sudo fc-cache -vf ~/.fonts/  # Atualiza o cache de fontes

        fi

        if [ -f ~/.config/fontconfig/conf.d/10-powerline-symbols.conf ]; then
            echo -e "${Br}Fonte OK, abortando...${Fm}"
            take_a_break
        else
            sudo wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

            if [ -d ~/.config/fontconfig/conf.d ]; then
                echo -e "${Br}Diretório OK${Fm}"
                take_a_break
            else
                sudo mkdir -p ~/.config/fontconfig/conf.d
            fi

            sudo chown $USER:$USER -R ~/.config/fontconfig/conf.d
            sudo mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

        fi

        echo '
. /usr/local/bin/powerline/powerline/bindings/bash/powerline.sh' >> ~/.bashrc

        source ~/.bashrc ;;

        0) encerra_menu ;;

        *) echo -e "${Br}Opção inválida, informe outra.${Fm}"; take_a_break ;;

	esac
}

#===============================================================================#
Menu() {
	while true; do
		clear
		echo ""
		sleep 0.05; echo -e ${Rd}"=========================================================================================="${Fm}
		sleep 0.05; echo -e ${Rd}"    █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗"${Fm}
		sleep 0.05; echo -e ${Rd}"   ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║"${Fm}
		sleep 0.05; echo -e ${Rd}"   ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║███████║   ██║   ██║██║   ██║██╔██╗ ██║"${Fm}
	   	sleep 0.05; echo -e ${Rd}"   ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║"${Fm}
		sleep 0.05; echo -e ${Rd}"   ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║"${Fm}
		sleep 0.05; echo -e ${Rd}"   ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"${Fm}
		sleep 0.05; echo -e ${Rd}"=========================================================================================="${Fm}
		sleep 0.05; echo -e ${Rd}"[ 0  ]"${Fm}${Br}" Sair"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 1  ]"${Fm}${Br}" Atualização do sistema"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 2  ]"${Fm}${Br}" Programas úteis"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 3  ]"${Fm}${Br}" Heroku"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 4  ]"${Fm}${Br}" MiniDLNA"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 5  ]"${Fm}${Br}" Git"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 6  ]"${Fm}${Br}" Atualização do PY (global)"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 7  ]"${Fm}${Br}" Bibliotecas importantes do PY"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 8  ]"${Fm}${Br}" Sublime Text"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 9  ]"${Fm}${Br}" Tmate"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 10 ]"${Fm}${Br}" Feh"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 11 ]"${Fm}${Br}" Google Chrome"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 12 ]"${Fm}${Br}" PostgreSQL"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 13 ]"${Fm}${Br}" Criação de pasta de trabalho"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 14 ]"${Fm}${Br}" Deezloader"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 15 ]"${Fm}${Br}" Remoção do libreoffice"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 16 ]"${Fm}${Br}" Node/NPM/Gtop"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 17 ]"${Fm}${Br}" ZSH"${Fm}
		sleep 0.05; echo -e ${Rd}"[ 18 ]"${Fm}${Br}" Ocultar dispositivos montados: Nautilus/Nemo"${Fm}
        sleep 0.05; echo -e ${Rd}"[ 19 ]"${Fm}${Br}" Tema ElementaryOS"${Fm}
        sleep 0.05; echo -e ${Rd}"[ 20 ]"${Fm}${Br}" Powerline no bash"${Fm}
		echo ""

		read -p $'\033[1;37mR: \033[m' digito

		[[ "$digito" =~ ^[[:alpha:]] ]] \
			&& echo -ne "\n${Rd}OPÇÃO INVÁLIDA!!!\nINFORME APENAS NÚMEROS!\n\n${Br}RETORNAR AO INÍCIO?${Fm}\n${Br}[S/N] R: ${Fm}" \
			&& read inicio || OPCAO $digito

			[[ $inicio == @(s|S|sim|Sim|SIM|y|Y|YES|yes) ]] && retorna_menu || encerra_menu
	done
}

checar_source
Menu
