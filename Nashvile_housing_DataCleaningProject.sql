-- Data Cleaning project

SELECT *
FROM Nashvile$

-- Standardize Date Format
SELECT SaleDate , CONVERT(DATE, SaleDate)AS newSaleDate
FROM Nashvile$;

-- For Some reasons this did not update the column, SO I will create a new column with name newSaleDate
UPDATE Nashvile$
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE Nashvile$
ADD newSaleDate DATE;

UPDATE Nashvile$
SET newSaleDate = CONVERT(DATE, SaleDate);

-- Populate Property address Where IS NULL Using SELF JOIN
SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM Nashvile$ a
	JOIN Nashvile$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL	;

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM Nashvile$ a
	JOIN Nashvile$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL	;

-- Breaking out Addresses into individual columns (Address, City, State)
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) AS Address
FROM Nashvile$;

ALTER TABLE Nashvile$
ADD newPropertyAddress NVARCHAR(255);

UPDATE Nashvile$
SET newPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE Nashvile$
ADD newPropertyCity NVARCHAR(255);

UPDATE Nashvile$
SET newPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress));

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM Nashvile$

ALTER TABLE Nashvile$
ADD newOwnerAddress NVARCHAR(255);

UPDATE Nashvile$
SET newOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE Nashvile$
ADD newOwnerCity NVARCHAR(255);

UPDATE Nashvile$
SET newOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE Nashvile$
ADD newOwnerState NVARCHAR(255);

UPDATE Nashvile$
SET newOwnerState =	PARSENAME(REPLACE(OwnerAddress, ',','.'),1);

-- Change Y and N to Yes and No in the SoldAsVacant column
SELECT 
	DISTINCT(SoldAsVacant), COUNT(SoldAsvacant) CNT
	FROM Nashvile$
	GROUP BY SoldAsVacant
	ORDER BY 2;

SELECT 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
	FROM Nashvile$;

UPDATE Nashvile$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID ) row_num
FROM Nashvile$ )
DELETE FROM RowNumCTE
WHERE row_num > 1;

-- Delete unused Columns
ALTER TABLE Nashvile$
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;