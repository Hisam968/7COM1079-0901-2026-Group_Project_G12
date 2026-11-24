# ---------------------------------------------------------------------
# SECTION 1. Prepare the data                                   (Alif)
# ---------------------------------------------------------------------
df <- read.csv("data/raw/WLD_RTFP_country_2023-10-02.csv")
print(colnames(df))
print(nrow(df))

# Keep the 12 months before and the 12 months after the invasion (24 Feb 2022)
df$date <- as.Date(df$date)
df <- subset(df, date >= as.Date("2021-03-01") & date <= as.Date("2023-02-01"))
df$period <- ifelse(df$date < as.Date("2022-03-01"), "Before", "After")

# Region of each country, by its ISO3 code (MENA = Middle East and North Africa)
df$region <- ifelse(df$ISO3 %in% c("IRQ", "LBN", "SYR", "YEM"), "MENA",
                    ifelse(df$ISO3 %in% c("AFG", "LAO", "MMR", "HTI"), "Asia & Caribbean",
                           "Sub-Saharan Africa"))
print(table(df$region, df$period))