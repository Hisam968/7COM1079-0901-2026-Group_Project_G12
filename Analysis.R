# =====================================================================
# 7COM1079 Team Research and Development Project (ds243)
# RQ: Is there a difference in the mean change in year-on-year food price
# inflation (12 months before vs 12 months after Russia's invasion of
# Ukraine) between Sub-Saharan Africa, MENA, and Asia & the Caribbean?
# =====================================================================



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


# Average inflation for each country, before and after the invasion
before <- aggregate(Inflation ~ country + region, data = subset(df, period == "Before"), FUN = mean)
after  <- aggregate(Inflation ~ country + region, data = subset(df, period == "After"),  FUN = mean)
colnames(before)[3] <- "inflation_before"
colnames(after)[3]  <- "inflation_after"










