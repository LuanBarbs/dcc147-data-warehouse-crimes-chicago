# Descrição da Base de Dados — Crimes em Chicago

## Fonte
Dataset público do portal data.gov, extraído do sistema CLEAR (Citizen Law Enforcement
Analysis and Reporting) do Departamento de Polícia de Chicago. Cobre incidentes de crime
reportados de 2001 até o presente, com atualização diária, excluindo os últimos sete dias.

## Observações importantes
- Endereços são anonimizados ao nível do quarteirão para proteger vítimas
- Os dados refletem registros preliminares e podem ser alterados após investigação
- Não são recomendados para comparações temporais absolutas (possibilidade de erro humano/mecânico)
- Assassinatos possuem um registro por vítima; demais crimes, um registro por incidente

## Atributos

| Coluna               | Descrição                                                       |
|----------------------|-----------------------------------------------------------------|
| ID                   | Identificador único do incidente                                |
| Case Number          | Número do boletim de ocorrência (RD Number)                     |
| Date                 | Data e hora do incidente                                        |
| Block                | Endereço anonimizado ao nível do quarteirão                     |
| IUCR                 | Código Illinois Uniform Crime Reporting — classifica o crime    |
| Primary Type         | Categoria principal do crime (ex: THEFT, BATTERY)               |
| Description          | Subcategoria do crime dentro do Primary Type                    |
| Location Description | Tipo de local onde ocorreu (ex: STREET, RESIDENCE)              |
| Arrest               | Indica se houve prisão (true/false)                             |
| Domestic             | Indica se o crime foi de natureza doméstica (true/false)        |
| Beat                 | Menor unidade geográfica de patrulha policial                   |
| District             | Distrito policial — agrupa vários beats                         |
| Ward                 | Divisão política/administrativa da cidade                       |
| Community Area       | Uma das 77 áreas comunitárias oficiais de Chicago               |
| FBI Code             | Classificação federal do crime (National Incident-Based)        |
| X Coordinate         | Coordenada X no sistema estatal de Illinois (ESRI)              |
| Y Coordinate         | Coordenada Y no sistema estatal de Illinois (ESRI)              |
| Year                 | Ano do incidente (derivado de Date)                             |
| Updated On           | Data da última atualização do registro                          |
| Latitude             | Latitude geográfica (aproximada ao quarteirão)                  |
| Longitude            | Longitude geográfica (aproximada ao quarteirão)                 |
| Location             | Par lat/long combinado em formato texto                         |

## Relações identificadas entre atributos

- **IUCR → Primary Type + Description**: o código IUCR determina a categoria e subcategoria
  do crime — base para a dimensão de tipo de crime.
- **Beat → District**: beats se agrupam em distritos — hierarquia geográfica policial natural.
- **District → Ward / Community Area**: diferentes recortes administrativos da mesma cidade,
  úteis para análises políticas vs. operacionais.
- **Date → Year**: Year é derivado de Date; ambos servirão para a dimensão tempo.
- **FBI Code → Primary Type**: classificação paralela ao IUCR, de âmbito federal —
  permite análises comparativas nacionais.
- **Latitude/Longitude ↔ Block**: a localização geográfica é sempre aproximada ao
  quarteirão, nunca ao endereço exato.