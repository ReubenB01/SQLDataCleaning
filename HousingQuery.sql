SELECT * 
FROM HousingData

-- Populate Propetry Address data (fill in null values)

SELECT PropertyAddress
FROM HousingData

SELECT *
FROM HousingData
WHERE PropertyAddress IS NULL

SELECT table1.ParcelID, table1.PropertyAddress, table2.ParcelID, table2.PropertyAddress, ISNULL(table1.PropertyAddress, table2.PropertyAddress)
FROM HousingData table1
JOIN HousingData table2
	on table1.ParcelID = table2.ParcelID
	AND table1.UniqueID <> table2.UniqueID
WHERE table1.PropertyAddress IS NULL

UPDATE table1
SET PropertyAddress = ISNULL(table1.PropertyAddress, table2.PropertyAddress)
FROM HousingData table1
JOIN HousingData table2
	on table1.ParcelID = table2.ParcelID
	AND table1.UniqueID <> table2.UniqueID

SELECT *
FROM HousingData
WHERE PropertyAddress IS NULL


-- Breaking up address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM HousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) AS city
FROM HousingData

ALTER TABLE HousingData
Add ProperySplitAddress VARCHAR(100)

UPDATE  HousingData
SET ProperySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingData
Add ProperySplitCity VARCHAR(100)

UPDATE HousingData
SET ProperySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress))

SELECT * 
FROM HousingData

SELECT OwnerAddress
FROM HousingData


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress VARCHAR(100)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE HousingData
ADD OwnerSplitCity VARCHAR(100)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE HousingData
ADD OwnerSplitState VARCHAR(100)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM HousingData

-- Change entries to a single format (Yes or No) 

SELECT DISTINCT(SoldAsVacant)
FROM HousingData

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM HousingData
GROUP BY SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant)
FROM HousingData

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM HousingData
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

SELECT *
FROM HousingData

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, PropertyAddress

SELECT *
FROM HousingData