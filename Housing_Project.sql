SELECT *
  FROM [DataCleaningProject].[dbo].[NashvilleHousing]
-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM [DataCleaningProject].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-- Populate Property Address Data
SELECT *
  FROM [DataCleaningProject].[dbo].[NashvilleHousing]
  WHERE PropertyAddress is null
  ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM [DataCleaningProject].[dbo].[NashvilleHousing] a
JOIN [DataCleaningProject].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)

FROM [DataCleaningProject].[dbo].[NashvilleHousing] a
JOIN [DataCleaningProject].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address Into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)- 1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address

FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)- 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold As Vacant Field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM DataCleaningProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		Partition By ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY
										UniqueID
										) row_num

FROM DataCleaningProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--Order By PropertyAddress


-- Delete Unused Columns 
SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
