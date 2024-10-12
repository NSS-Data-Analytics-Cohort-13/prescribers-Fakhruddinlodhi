SELECT * FROM cbsa;

SELECT * FROM drug;

SELECT * FROM fips_county;

SELECT * FROM overdose_deaths;

SELECT * FROM population;

SELECT * FROM prescriber;

SELECT * FROM prescription;

SELECT * FROM zip_fips;


 
    -- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi
	, SUM(total_claim_count) as total_count
FROM prescription
GROUP BY npi
ORDER BY total_count DESC
LIMIT 1;
--Answer 1a 		NPI= 1881634483 with total_count of 99707




--     1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT prescriber.nppes_provider_first_name
	, prescriber.nppes_provider_last_org_name
	, prescriber.specialty_description
	, SUM(prescription.total_claim_count) as total_count
FROM prescription
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
GROUP BY prescriber.nppes_provider_first_name
	, prescriber.nppes_provider_last_org_name
	, prescriber.specialty_description
ORDER BY total_count DESC
LIMIT 1;
--Answer 1b		Bruce Pendley Family Practice with 99707 total count of claims




--     2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescriber.specialty_description
	, SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
on prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 1;
--Answer 2a			Family Practice with 9752347 claims



--     2b. Which specialty had the most total number of claims for opioids?

SELECT prescriber.specialty_description
	, SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
on prescriber.npi = prescription.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 1;
--Answer 2b			Nurse Practitioner with 900845


--		2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--		2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
--for later on if done with full assigment !!!!!!!!!*************!!!!!!!!






 
--     3a. Which drug (generic_name) had the highest total drug cost?

SELECT drug.generic_name
	, SUM(prescription.total_drug_cost) AS total_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE prescription.total_drug_cost IS NOT NULL
GROUP BY drug.generic_name
ORDER BY total_cost DESC
LIMIT 5;
--Answer		"PIRFENIDONE" had the highest toal drug cost of 2829174.3


--     3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT drug.generic_name
	, ROUND(SUM (prescription.total_drug_cost) / SUM (prescription.total_day_supply), 2)  AS daily_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE prescription.total_drug_cost IS NOT NULL
	AND prescription.total_30_day_fill_count IS NOT NULL
GROUP BY drug.generic_name
ORDER BY daily_cost DESC
LIMIT 5;
--Answer			"ASFOTASE ALFA"	4659.20




-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name,
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiobiotic'
											ELSE 'neither'
	END AS drug_type
FROM drug
ORDER BY drug_type ASC,
	drug_name ASC;




--     4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT 
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiobiotic'
											ELSE 'neither'
	END AS drug_type
	, ROUND(SUM(prescription.total_drug_cost))::Money AS total_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE (drug.opioid_drug_flag='Y' OR drug.antibiotic_drug_flag='Y')
GROUP BY drug_type
ORDER BY total_cost DESC;
--Answer 4b		"opioid"	$105,080,626.00




--     5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(state) AS cbsa_tn
FROM cbsa AS c
INNER JOIN fips_county AS F
ON c.fipscounty = f.fipscounty 
WHERE state = 'TN'
ORDER BY cbsa_tn DESC;


--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT c.cbsaname
	, SUM(population) AS total_population
FROM cbsa AS c
INNER JOIN fips_county AS f
ON c.fipscounty = f.fipscounty
INNER JOIN population
ON population.fipscounty = f.fipscounty
WHERE state = 'TN'
GROUP BY c.cbsaname
ORDER BY total_population DESC;


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT   f.county
	,  SUM(population) as Total_Population
FROM cbsa AS c
RIGHT JOIN fips_county AS f
	ON c.fipscounty = f.fipscounty
RIGHT JOIN population pop
	ON pop.fipscounty = f.fipscounty
WHERE state = 'TN' AND c.cbsaname IS NULL
GROUP BY f.county
ORDER BY Total_Population desc
LIMIT 1;


--6a
--Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name
	, total_claim_count
FROM prescription
WHERE total_claim_count >= '3000';


--6b
--For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT a.drug_name
	, total_claim_count
	,	CASE 
			WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
										ELSE NULL
		END AS opioidFlag
FROM prescription a 
JOIN drug b 
	ON a.drug_name = b.drug_name
where total_claim_count >= '3000';


--6c
--Add another column to you answer from the previous part which gives the prescriber first and last --name associated with each row.
Select	a.drug_name
	,	total_claim_count
	,	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
									ELSE NULL 
		END AS opioidFlag
		, CONCAT(c.nppes_provider_first_name, ' ', c.nppes_provider_last_org_name) AS full_name
FROM prescription a 
INNER JOIN drug b 
	ON a.drug_name = b.drug_name
INNER JOIN prescriber c 
	ON c.npi = a.npi
WHERE total_claim_count >= '3000';


--7 The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--7a First, create a list of all npi/drug_name combinations for pain management specialists
 --(specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city =
 --'NASHVILLE'),
--where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before
--running it.
--You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT prescriber.npi
	,	drug.drug_name
From drug 
CROSS JOIN prescriber
WHERE prescriber.specialty_description = 'Pain Management' 
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y';



--7b
 --Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
 --whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

 SELECT	c.npi
	,	a.drug_name
	,	specialty_description
	,	nppes_provider_city
	,	opioid_drug_flag
From drug a 
CROSS JOIN prescriber c
WHERE c.specialty_description = 'Pain Management' 
	AND c.nppes_provider_city = 'NASHVILLE'
	AND a.opioid_drug_flag = 'Y';




