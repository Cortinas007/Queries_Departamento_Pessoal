# 📊 Automação e Análise de Dados - Departamento Pessoal (DP)

Este repositório contém consultas SQL (Queries) desenvolvidas para solucionar problemas reais e otimizar a rotina operacional do Departamento Pessoal, atuando diretamente no banco de dados relacional de um sistema ERP.

## 🎯 O Problema de Negócio

No dia a dia do DP, o cruzamento de dados entre descontos em folha (como empréstimos e crédito trabalhador), histórico de afastamentos e cálculos de folha costuma ser um processo manual, demorado e sujeito a erros quando feito exclusivamente em planilhas. 

O objetivo destas consultas é **automatizar a conciliação financeira e o levantamento de dados**, garantindo que as regras de negócio sejam aplicadas diretamente na fonte. Isso inclui alinhar descontos com os saldos reais dos colaboradores, isolando e tratando corretamente os casos complexos (férias, licenças médicas prolongadas e desligamentos).

## 🛠️ Tecnologias e Técnicas Utilizadas

* **Linguagem/Banco:** SQL (PostgreSQL)
* **Técnicas Avançadas Aplicadas:**
  * **CTEs (Common Table Expressions):** Modularização de regras de negócio complexas antes da execução do relatório principal.
  * **Window Functions:** Uso de `ROW_NUMBER`, `LAG` e `LEAD` para análise de histórico cronológico (ex: evolução salarial, quebra de recibos de férias).
  * **Lógica Condicional:** Uso avançado de `CASE WHEN` para mapeamento de status dinâmico do colaborador.
  * **Tratamento de Exceções:** Uso de `COALESCE` e `NULLIF` para blindar o código contra erros matemáticos e dados vazios.
  * **Modelagem Relacional:** Múltiplos `JOINs` (INNER e LEFT) garantindo a integridade referencial sem perda ou duplicação de dados (Produto Cartesiano).

## 📂 Arquivos do Projeto

* `Queries_consolidacao_credito_trabalhador.sql`: Consulta responsável por cruzar o valor das parcelas de empréstimos com os valores efetivamente descontados no cálculo da folha, mapeando o status exato do colaborador (Trabalhando, Afastado ou Desligado) na competência filtrada.

---
*🔒 **Nota de Segurança e Privacidade:** Todos os nomes de tabelas, colunas, regras específicas de negócio e dados contidos nos códigos deste repositório foram previamente editados, anonimizados ou substituídos por dados genéricos. O objetivo é proteger a integridade corporativa e a Lei Geral de Proteção de Dados (LGPD), servindo o repositório estritamente como portfólio de demonstração de lógica de programação.*
