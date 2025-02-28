# Linux Setup - Instalação Automática

Este repositório contém scripts que automatizam a configuração de um ambiente Linux, incluindo:

- Atualização dos pacotes do sistema.
- Instalação dos pacotes: `openssh-server`, `micro`, `btop`, `python3` e `tailscale`.
- Instalação/atualização do Docker e Portainer.
- Criação de um container Nginx para servir um site a partir de um diretório do host (por exemplo, `/home/<seu-usuario>/meu-site`).
- Cópia automática dos arquivos padrão do Nginx para o diretório do site, caso este esteja vazio.

## Estrutura do Repositório

```plaintext
linux_setup/
└── meu-site/
    ├── index.html
    ├── css/
    │   └── style.css
    ├── js/
    │   └── main.js
    ├── imagens/
    │   ├── 1.png
    │   ├── 2.png
    │   ├── 3.png
    │   └── ... até 99.png
    ├── deploy.sh
    └── update_site.sh

```

Instalação e Configuração do Ambiente
Para instalar e configurar o ambiente (incluindo Docker, Portainer, Tailscale e demais pacotes), execute:
```bash
curl -fsSL https://raw.githubusercontent.com/sandman21vs/linux_setup/main/install.sh -o /tmp/install.sh && sudo bash /tmp/install.sh
```
Observação: Certifique-se de executar o comando com sudo para garantir os privilégios necessários.


Deploy do Site
O script deploy.sh cria um container Nginx que monta o diretório do site e o serve na porta 9001.
Acesse o site em: http://<SEU_IP>:9001

Para fazer o deploy, execute:
```bash
curl -fsSL https://raw.githubusercontent.com/sandman21vs/linux_setup/main/meu-site/deploy.sh -o /tmp/deploy.sh && sudo bash /tmp/deploy.sh
```
Atualização do Site
Para sincronizar os arquivos do repositório GitHub com o diretório do site no seu Linux (por exemplo, /home/<seu-usuario>/meu-site), use o script update_site.sh:
```bash
curl -fsSL https://raw.githubusercontent.com/sandman21vs/linux_setup/main/meu-site/update_site.sh -o /tmp/update_site.sh && bash /tmp/update_site.sh
```

Apagar tudo que foi instalado 
Para apagar os arquivos do repositório GitHub com o diretório do site no seu Linux (por exemplo, /home/<seu-usuario>/meu-site), use o script uninstall_all.sh:
```bash
curl -fsSL https://raw.githubusercontent.com/sandman21vs/linux_setup/main/uninstall_all.sh -o /tmp/uninstall_all.sh && sudo bash /tmp/uninstall_all.sh
```

Acesso ao Portainer
O Portainer é instalado e executado em um container Docker para gerenciar seus containers.
Acesse o Portainer em: https://<SEU_IP>:9443

Observação: Ao acessar via HTTPS, pode ser necessário aceitar um certificado não confiável se estiver usando um certificado autoassinado.

Estrutura Básica do Site
O site base possui:

index.html: Página principal com uma breve apresentação.
css/style.css: Estilos CSS para o layout.
js/main.js: Scripts JavaScript para interatividade.
imagens/: Pasta com imagens numeradas de 1.png a 99.png (a imagem 1.png será usada no canto superior esquerdo para representar o usuário).
Você pode personalizar estes arquivos conforme sua necessidade para criar seu site, adicionar uma loja, links, ou qualquer outra funcionalidade.

Personalização
Este projeto é uma base para que você possa criar, personalizar e hospedar seu próprio site de forma simplificada e em autocustódia. Basta editar os arquivos conforme o seu desejo e usar os scripts de deploy e atualização para manter seu site atualizado.

