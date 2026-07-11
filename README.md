# dcc147-data-warehouse-crimes-chicago
Repositório para o Trabalho Final da Disciplina DCC174 - Data Warehouse. O trabalho consiste na análise dos dados de crimes cometidos na cidade  de Chicago, com o objetivo de produzir soluções — relatórios, indicadores e dashboards —  que auxiliem gestores a compreender as ocorrências de crime na cidade. 

---

## Estrutura

- `data/` csv de crimes de chicago aqui
- `dbt/` modelos dbt
- `reports/` arquivos .pbix e .rdl
- `docs/` documentação, diagramas, etc.
- `src/` códigos, como load_data.py que faz a carga.

---

## Stack de Ferramentas
| Camada | Ferramenta | Função |
|----------|----------|----------|
| Storage/DW | PostgreSQL Local | Armazena a fonte transacional e o modelo dimensional  |
| Transformação (ETL) | dbt-core + dbt-postgres | Define modelos SQL versionados, snapshots para SCDs, documentação e linhagem automáticas |
| Modelo semântico | Power BI Desktop (modelo de dados + DAX) | Substitui o “cubo” XMLA tradicional — relações, hierarquias e medidas vivem dentro do .pbix |
| Relatórios estáticos | Power BI Report Builder | Relatórios paginados com parâmetros (filtros) |
| Relatórios dinâmicos | Power BI Desktop | Slicers, drill-down, drill-through, cross-filter |
| Dashboards | Power BI Desktop | Páginas interativas com cross filtering nativo |

---

## Configurações
- Versão PostgreSQL: 18.4-2-windows-x64