# Primeiros passos com raspberryPI 

## Liberações padrão
- Liberar ssh
    - após instalar o raspios via criador de discos com a imagem versão "Raspberry Pi OS Lite" [https://www.raspberrypi.com/software/operating-systems](https://www.raspberrypi.com/software/operating-systems)
    - Acesse via hdmi e libere acesso ssh 
        - `sudo raspi-config`
        - Interface options
        - Enable/Disable remote command line access using SSH
    Logo após esta liberação poderá acessar via ssh do seu pc principal.
- Criar chave de acesso ssh
    No PC principal:
```
$ ssh-keygen 
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/carlos/.ssh/id_ed25519): id_raspios
Enter passphrase for "id_raspios" (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in id_raspios
Your public key has been saved in id_raspios.pub
The key fingerprint is:
SHA256:DSeFQbxil5MKRzChJRgmWdv9j1CZXIOW98yojqP0zqY carlos@carlos-ubuntu
The key's randomart image is:
+--[ED25519 256]--+
|o*o =o oo=+      |
|=  * o..*=..     |
|  o ....B=.=     |
|    . +o*=. +    |
|     +.+So.      |
|    .  o. .      |
|   . o+ .        |
|    E=+.         |
+----[SHA256]-----+
```
depois copie para o rasp:
```
$ ssh-copy-id -i id_raspios carlos@192.168.0.8
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "id_raspios.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
carlos@192.168.0.8's password: 

Number of key(s) added: 1

Now try logging into the machine, with: "ssh -i ./id_raspios 'carlos@192.168.0.8'"
and check to make sure that only the key(s) you wanted were added.
```
Após isso, pode acessar o rasp direto sem senha, Criei um alias em .bash_aliases com o conteudo:
```
alias sshpired='ssh carlos@192.168.0.8'
# acesso:
$ sshpired
```
- Adicionar usuário ao grupo sudo, para não pedir senha a todo momento:
```
$ sudo usermod carlos -a -G adm,sudo,users,netdev
$ sudo apt update
```
Agora seu Rasp está pronto para iniciar as configurações necessárias para compor um cluster Kubernetes

