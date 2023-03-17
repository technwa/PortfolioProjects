/* DATA CLEANING IN SQL SERVER*/

-- Call up table

SELECT TOP 1000
FROM PortfolioProject..NashvilleHousing

-- Convert Datetime to Date format
-- 1st add new field

ALTER TABLE NashvilleHousing
ADD SalesDate date

-- Update

UPDATE NashvilleHousing
SET SalesDate= CONVERT(Date, Saledate)

-- delete old date

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate


-- to update missing addresses in the PropertyAddress field; Confirming output in SELECT

SELECT a.parcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b 
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

-- Nest ISNULL in UPDATE

UPDATE a 
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b 
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

--Split Address into individual fields

SELECT PARSENAME(REPLACE(PropertyAddress,',','.'),2),
PARSENAME(REPLACE(PropertyAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

-- create new fields for street and city

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(200)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(200)

--Update

UPDATE NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress,',','.'),2)

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress,',','.'),1)

--Split OwnerAddress into street, city, state

SELECT PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

--  create new fields for street, city, state

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(200)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(200)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(200)

-- Update

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(owneraddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)

-- replace Y with Yes, N with No in SoldAsVacant Field; Confirming output in SELECT

SELECT SoldAsVacant, 
CASE 
	WHEN SoldAsVacant ='Y'THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing
WHERE SoldAsVacant IN ('Y','N')

-- Nesting in UPDATE

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant ='Y'THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END
WHERE SoldAsVacant IN ('Y','N')

-- Identify and Remove duplicates 
-- Create CTE

WITH Nashvillehome
AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								Salesdate,
								LegalReference
								ORDER BY
									UniqueID) AS Row_num
FROM PortfolioProject..NashvilleHousing
) 
DELETE 
FROM Nashvillehome
WHERE Row_num >1

-- Deleting irrelevant fields

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN 
PropertyAddress, OwnerAddress, TaxDistrict

-- renaming fields for clarity
-- 1st, create new fields with prefrred names 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDate Date,
PropertyAddress nvarchar(255),
PropertyCity nvarchar(255),
OwnerAddress nvarchar(255),
OwnerCity nvarchar(255),
OwnerState nvarchar(255)

-- Updating

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate= SalesDate,
	PropertyAddress = PropertySlpitAddress,
	PropertyCity = PropertyAddressSlpitCity,
	OwnerAddress = OwnerSplitAddress,
	OwnerCity = OwnerSplitCity,
	OwnerState = OwnerSplitState
	
	--deleting the old replaced fields

	ALTER TABLE PortfolioProject..NashvilleHousing
	DROP COLUMN SalesDate, 
				PropertySlpitAddress,
				PropertyAddressSlpitCity,
				OwnerSplitAddress,
				OwnerSplitCity,
				OwnerSplitState


-- Creating View - The cleaned data 

DROP VIEW IF EXISTS NashvillePropertyData
CREATE VIEW NashvillePropertyData
AS 
SELECT
[UniqueID ],
ParcelID,
PropertyAddress,
PropertyCity,
SaleDate,
SalePrice,
LegalReference,
SoldAsVacant,
OwnerName,
OwnerAddress,
OwnerCity,
OwnerState,
Acreage,
LandValue,
BuildingValue,
TotalValue,
YearBuilt,
Bedrooms,
Fullbath,
halfbath
FROM PortfolioProject..NashvilleHousing

-- To view cleaned data
SELECT *
FROM NashvillePropertyData
ORDER BY ParcelID