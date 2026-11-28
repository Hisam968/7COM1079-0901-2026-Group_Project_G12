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



# One row per country: before, after, and the change
countries <- before
countries$inflation_after <- after$inflation_after
countries$change <- countries$inflation_after - countries$inflation_before
countries$region <- factor(countries$region,
                           levels = c("Sub-Saharan Africa", "MENA", "Asia & Caribbean"))
print(table(countries$region))



# Save the country-level data
dir.create("data/processed", showWarnings = FALSE)
write.csv(countries, "data/processed/country_change.csv", row.names = FALSE)
print(head(countries))


# ---------------------------------------------------------------------
# SECTION 2. Descriptive statistics
# ---------------------------------------------------------------------
print(summary(countries$change))
print(sd(countries$change))


print(summary(countries$inflation_before))
print(summary(countries$inflation_after))

print(aggregate(change ~ region, data = countries, FUN = median))
print(aggregate(change ~ region, data = countries, FUN = mean))


print(aggregate(cbind(inflation_before, inflation_after) ~ region, data = countries, FUN = median))


# ---------------------------------------------------------------------
# SECTION 3. Figure 1 - histogram of the change               
# ---------------------------------------------------------------------
dir.create("figures", showWarnings = FALSE)
png("figures/fig1_histogram.png", width = 900, height = 650)
hist(countries$change,
     main = "Figure 1. Change in food inflation across 25 countries",
     xlab = "Change in food inflation (percentage points, after minus before)",
     ylab = "Number of countries")
abline(v = 0, lty = 2)
abline(v = median(countries$change), col = "red", lwd = 2)
legend("topleft",
       legend = c("No change (0)", "Median change"),
       col = c("black", "red"),
       lty = c(2, 1),
       bty = "n")
dev.off()
hist(countries$change, main = "Figure 1. Change in food inflation across 25 countries", xlab = "Change in food inflation (percentage points, after minus before)", ylab = "Number of countries")


# ---------------------------------------------------------------------
# SECTION 4.  Box Plots
# ---------------------------------------------------------------------

region_cols <- c("steelblue", "tomato", "seagreen")
png("figures/fig2_boxplot_by_region.png", width = 900, height = 650)
boxplot(change ~ region, data = countries,
        col = region_cols,
        main = "Figure 2. Change in food inflation by region",
        xlab = "Region",
        ylab = "Change in food inflation (percentage points, after minus before)")
        abline(h = 0, lty = 2)
        legend("topright",
               legend = paste(levels(countries$region), " (n = ", table(countries$region), ")"),
               fill   = region_cols,
               bty    = "n")
dev.off()

# ---------------------------------------------------------------------
# SECTION 5. Summary table for the report                     (Marvin)
# ---------------------------------------------------------------------
summary_table <- aggregate(change ~ region, data = countries, FUN = median)
colnames(summary_table)[2] <- "median_change"
summary_table$n <- as.vector(table(countries$region))
print(summary_table)



