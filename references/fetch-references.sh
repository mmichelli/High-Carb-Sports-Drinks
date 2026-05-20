#!/usr/bin/env bash
# Download open-access PDFs for every citation on the Marathon Drink Calculator
# page. Run from the references/ directory:
#
#   cd references && bash fetch-references.sh
#
# Paywalled papers are skipped with a note. Re-run any time — existing files
# are not re-downloaded.

set -u

ua="Mozilla/5.0 (Marathon-Drink-Calculator/1.0; +https://github.com/mmichelli/High-Carb-Sports-Drinks)"

fetch() {
  local name="$1"
  local url="$2"
  local file="${name}.pdf"
  if [[ -s "$file" ]]; then
    printf "  %-48s  exists (%s)\n" "$file" "$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null) bytes"
    return 0
  fi
  printf "  %-48s  fetching...\n" "$file"
  if curl -sSL --fail --max-time 60 -A "$ua" "$url" -o "$file" 2>/dev/null; then
    printf "  %-48s  ok (%s bytes)\n" "$file" "$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)"
  else
    rm -f "$file"
    printf "  %-48s  FAILED\n" "$file"
  fi
}

echo "Carbohydrate intake & oxidation"
fetch burke-2019-iaaf-consensus              "https://worldathletics.org/download/download?filename=23fb9de0-6699-4d5b-b075-42f5da5518f5.pdf"
fetch hearris-2022-120gh-multiformat          "https://journals.physiology.org/doi/pdf/10.1152/japplphysiol.00091.2022"
fetch jentjens-jeukendrup-2005-glu-fru        "https://www.cambridge.org/core/services/aop-cambridge-core/content/view/5978786559A73EDEFC6DCD272A773E3A/S0007114505000619a.pdf"
fetch trommelen-2017-sucrose-fructose         "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5331598/pdf/nutrients-09-00167.pdf"
fetch podlogar-wallis-2022-new-horizons       "https://pmc.ncbi.nlm.nih.gov/articles/PMC9734239/pdf/40279_2022_Article_1757.pdf"
fetch viribay-2020-120gh-marathon             "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7284742/pdf/nutrients-12-01367.pdf"
fetch podlogar-2022-fru-malto-ratio           "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9560939/pdf/421_2022_Article_5018.pdf"

echo "Gut training & gastric emptying"
fetch jeukendrup-2017-training-the-gut        "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5371619/pdf/40279_2017_Article_690.pdf"
# Murray 1999 (Int J Sport Nutr) — paywalled, PubMed abstract only
echo "  murray-1999-cho-gastric-emptying.pdf            paywalled (PMID 10477362)"

echo "Hydration & sodium"
fetch lara-2016-sweat-sodium-marathoners      "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4966593/pdf/40279_2016_Article_503.pdf"
fetch hoffman-stuempfle-2015-ultra-sodium     "https://pmc.ncbi.nlm.nih.gov/articles/PMC4688305/pdf/40279_2015_Article_398.pdf"
# Sawka 2007 ACSM hypohydration position stand — paywalled
echo "  sawka-2007-acsm-hypohydration.pdf               paywalled (PMID 17277604)"

echo "Caffeine & bicarbonate"
# Burke 2008 caffeine review — Appl Physiol Nutr Metab, paywalled
echo "  burke-2008-caffeine-sport-perf.pdf              paywalled (PMID 19088794)"
fetch grgic-2021-issn-bicarb-position         "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8427947/pdf/12970_2021_Article_458.pdf"

# Jentjens-Achten-Jeukendrup 2005 Metabolism (sucrose) — Elsevier, paywalled
echo "  jentjens-achten-2005-metabolism-sucrose.pdf     paywalled (PMID 15877301)"

echo
echo "Done. Files saved to $(pwd)"
ls -la *.pdf 2>/dev/null | awk '{print "  ", $9, "(" $5 " bytes)"}'
