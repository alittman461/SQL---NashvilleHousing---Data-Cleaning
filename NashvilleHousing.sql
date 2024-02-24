SELECT * FROM housing_project.housing_project

-- Standardize Date Format

SELECT "SaleDate"
FROM housing_project.housing_project

-- Populate Property Address Data

SELECT "PropertyAddress"
FROM housing_project.housing_project
WHERE "PropertyAddress" IS NULL

SELECT *
FROM housing_project.housing_project
WHERE "PropertyAddress" IS NULL

SELECT *
FROM housing_project.housing_project
--WHERE "PropertyAddress" IS NULL
ORDER BY "ParcelID"

SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress"
FROM housing_project.housing_project a
JOIN housing_project.housing_project b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL

SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress", COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM housing_project.housing_project a
JOIN housing_project.housing_project b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL

UPDATE housing_project.housing_project
SET "PropertyAddress" = COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM housing_project.housing_project a
JOIN housing_project.housing_project b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL

-- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT "PropertyAddress"
FROM housing_project.housing_project
--WHERE "PropertyAddress" IS NULL
--ORDER BY "ParcelID"

SELECT
SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',') -1) AS Address,
SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',') +1, LENGTH("PropertyAddress")) AS City
FROM housing_project.housing_project

ALTER TABLE housing_project.housing_project
ADD "PropertySplitAddress" VARCHAR(255);

UPDATE housing_project.housing_project
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',') -1)

ALTER TABLE housing_project.housing_project
ADD "PropertySplitCity" VARCHAR(255);

UPDATE housing_project.housing_project
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',') +1, LENGTH("PropertyAddress"))

SELECT * FROM housing_project.housing_project

-- Owner Address

SELECT "OwnerAddress"
FROM housing_project.housing_project

SELECT
SPLIT_PART("OwnerAddress",',',1),
SPLIT_PART("OwnerAddress",',',2),
SPLIT_PART("OwnerAddress",',',3)
FROM housing_project.housing_project

ALTER TABLE housing_project.housing_project
ADD "OwnerSplitAddress" VARCHAR(255);

UPDATE housing_project.housing_project
SET "OwnerSplitAddress" = SPLIT_PART("OwnerAddress",',',1)

ALTER TABLE housing_project.housing_project
ADD "OwnerSplitCity" VARCHAR(255);

UPDATE housing_project.housing_project
SET "OwnerSplitCity" = SPLIT_PART("OwnerAddress",',',2)

ALTER TABLE housing_project.housing_project
ADD "OwnerSplitState" VARCHAR(255);

UPDATE housing_project.housing_project
SET "OwnerSplitState" = SPLIT_PART("OwnerAddress",',',3)

SELECT * FROM housing_project.housing_project

-- Change Y/N to Yes/No in "Sold as Vacant" column

SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM housing_project.housing_project
GROUP BY "SoldAsVacant"

SELECT "SoldAsVacant"
, CASE
WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
WHEN "SoldAsVacant" = 'N' THEN 'No'
ELSE "SoldAsVacant"
END
FROM housing_project.housing_project

UPDATE housing_project.housing_project
SET "SoldAsVacant" = 
CASE
WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
WHEN "SoldAsVacant" = 'N' THEN 'No'
ELSE "SoldAsVacant"
END

SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM housing_project.housing_project
GROUP BY "SoldAsVacant"

-- Remove Duplicates

WITH row_num_cte AS(
SELECT ctid,
	ROW_NUMBER() OVER(
	PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SalePrice",
				 "SaleDate",
				 "LegalReference"
	ORDER BY "UniqueID"
	) row_num

FROM housing_project.housing_project
-- ORDER BY "ParcelID"
)
DELETE
FROM housing_project.housing_project
       USING row_num_cte
       WHERE row_num_cte.row_num > 1
             AND row_num_cte.ctid = housing_project.housing_project.ctid;
			 
-- Delete Unused Columns

SELECT * FROM housing_project.housing_project

ALTER TABLE housing_project.housing_project
DROP COLUMN "OwnerAddress"

ALTER TABLE housing_project.housing_project
DROP COLUMN "PropertyAddress"

ALTER TABLE housing_project.housing_project
DROP COLUMN "TaxDistrict"

ALTER TABLE housing_project.housing_project
DROP COLUMN "SaleDate"
