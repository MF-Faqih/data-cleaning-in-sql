/*

Data cleaning using SQL

Skills used: Join, Self Join, CTE's, Window Function, Aggregation Function, Creating Vieww, Conditional Expression, Converting Data Type, Alter Table, etc.

*/


SELECT * 
FROM NashvilleHouse.dbo.NashvilleHousing

-----------------------------------------------------------------------------


--- STANDARDIZE DATE FORMAT
 
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHouse.dbo.NashvilleHousing
-- Create new columns than assign the convert column value into it
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------


--- POPULATE PROPERTY ADDRESS DATA

SELECT * 
FROM NashvilleHouse.dbo.NashvilleHousing 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouse.dbo.NashvilleHousing AS a
JOIN NashvilleHouse.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouse.dbo.NashvilleHousing AS a
JOIN NashvilleHouse.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress 
FROM NashvilleHouse.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHouse.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
	PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Another way to split string using parsenam (easier way)
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), --- Doing it backwards bcoz the result doing it as well
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHouse.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvilleHousing

-----------------------------------------------------------------------------


-- CHANGE Y AND N TO Yes AND No IN 'Sold as Vacant' FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHouse.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHouse.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHouse.dbo.NashvilleHousing

-----------------------------------------------------------------------------


-- REMOVE DUPLICATE
--Every row that has same value in all 4 columns, will have different row_number
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
ORDER BY UniqueID) row_num
FROM NashvilleHouse.dbo.NashvilleHousing
--ORDER BY ParcelID
) --Remove row which has number bigger than 2 (duplciate)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-----------------------------------------------------------------------------


--DELETE UNUSED COLUMN(S)

ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM NashvilleHouse.dbo.NashvilleHousing