library(sparklyr)

sc <- spark_connect(master="local")
abbrev_spark <- copy_to(sc, abbrev, "abbrev")

dplyr::count(abbrev_spark$Protein_g > 10)

abbrev_collect <- collect()

