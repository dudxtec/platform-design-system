# Design System da plataforma

Fundação visual e comportamental de todos os repositórios `*-portal`.

| # | Documento | Conteúdo |
|---|---|---|
| 1 | [Auditoria](01-auditoria.md) | Estado dos 11 portais em outubro de 2026, com severidade e evidência |
| 2 | [Fundamentos](02-fundamentos.md) | Marca, atributos da interface e os 8 princípios obrigatórios |
| 3 | [Tokens](03-tokens.md) | Cores, tipografia, espaçamento, raios, elevação, camadas, movimento |
| 4 | [Layout](04-layout.md) | Shell, cabeçalho de página, filtros, conteúdo; wireframes |
| 5 | [Componentes](05-componentes.md) | Uso correto e incorreto, estados, variantes, acessibilidade |
| 6 | [Formulários e tabelas](06-formularios-e-tabelas.md) | Padrão único de CRUD, validação, listagem, paginação, ações em lote |
| 7 | [Dashboards e templates](07-dashboards-e-templates.md) | KPIs, gráficos e os 11 templates de tela |
| 8 | [Arquitetura](08-arquitetura.md) | Estrutura de pastas, nomenclatura, versionamento, regras de contribuição |
| 9 | [Migração](09-migracao.md) | Roadmap em 4 fases, por portal, com impacto, risco e esforço |

## Escopo

O design system é **Flutter**. Os seis portais de back-office (main, membership,
person, forms, reports, tenant) são Flutter Web e são o alvo principal.

Os cinco portais React (três de campanha, customer-bill e checkout-food) são
páginas públicas de fluxo curto. Eles seguem os mesmos tokens e princípios, mas
não há pacote web neste repositório; ver a seção "Portais web" em
[Arquitetura](08-arquitetura.md).

## Ver funcionando

```bash
cd example
flutter run -d chrome
```

A galeria traz os templates de dashboard, CRUD e cadastro e a página de
componentes, com alternância de tema. `?theme=dark`, `?page=list` e
`?embedded=true` na URL abrem direto em cada estado.
