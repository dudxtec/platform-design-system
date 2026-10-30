# Template de e-mail

Template base de todo e-mail que a plataforma envia (Amazon SES). Fica aqui
como referência da identidade visual; não faz parte do pacote Flutter (está
fora de `lib/`).

## Arquivos

- `email-base-dudx.html`: template com placeholders `{{ }}` preenchidos por
  quem envia o e-mail.
- `logo-dudx-email.png`: logo DUDX positivo, 200 x 44 px (exibido em
  100 x 22). Publicado em `https://stg001.dudx.cloud/logo-dudx-email.png`,
  endereço definitivo: não mover, porque e-mails já enviados apontam para ele.
  Origem: `logo.svg` de `dudxtec/keycloak-theme`.

## Estrutura

- Topo (fixo): faixa verde `#007172` com o nome do tenant em destaque, em texto.
- Meio (muda por operação): saudação, título, um parágrafo, resumo opcional em
  pares rótulo/valor, um único botão de largura total (52px), link de reserva
  e aviso opcional com borda laranja.
- Rodapé (fixo): nome do tenant, WhatsApp do tenant (linha removida quando não
  há número), motivo do envio, "Este endereço não recebe respostas.", política
  de privacidade e "Enviado pela plataforma" com o logo DUDX.

## Regras

- Só tabelas e estilo inline; nada de flex, grid, classes ou CSS externo.
- Largura máxima 600px, fluida no celular. Leitura pensada primeiro no
  aplicativo de e-mail do celular (Gmail, Outlook, Apple Mail).
- Botão com versão VML para o Outlook desktop.
- Uma ação por e-mail.
- Fonte Poppins quando o aplicativo tem; senão Arial.
- Pré-cabeçalho sempre preenchido.
- Remetente: `noreply@dudx.cloud`, com o nome do tenant como nome exibido.

## Campos

`assunto`, `pre_cabecalho`, `nome_tenant`, `primeiro_nome`, `titulo`, `texto`,
`rotulo`/`valor` (repetível), `texto_botao`, `url_acao`, `aviso`,
`whatsapp_tenant`, `motivo_envio`, `url_politica_privacidade`.

Blocos opcionais estão marcados com `INÍCIO` e `FIM` no HTML e podem ser
removidos inteiros.

## Pendências

- Teste de envio real pelo SES (Gmail e Outlook no celular, claro e escuro).
- Conferir SPF, DKIM e DMARC do `dudx.cloud`.
- Levar o visual ao tema de e-mail do Keycloak (`dudxtec/keycloak-theme`).
