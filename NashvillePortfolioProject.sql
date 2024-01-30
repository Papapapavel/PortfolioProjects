/* Data cleaning portfolio project */

Select *
From NashvilleHousing;

-------------------------------------------------------------------------------
--Standardize Date format 

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

--------------------------------------------------------------------------------\

--Populate Property Address data 

Select *
From NashvilleHousing
--Where PropertyAddress is null;
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a 
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a 
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;



-------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null;
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From NashvilleHousing



Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select * 
From NashvilleHousing




---------------------------------------------------------------------------------

-- CHange Y and N to Yes and NO in "Sold as Vacant" field


Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'Yes' Then 'Y'
	WHEN SoldAsVacant = 'No' Then 'N'
	ELSE SoldAsVacant
END AS SoldAsVacant
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	When SoldAsVacant = 'Yes' Then 'Y'
	WHEN SoldAsVacant = 'No' Then 'N'
	ELSE SoldAsVacant
END 

----------------------------------------------------------------------------------
-- Remove Duplicates 

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From NashvilleHousing
)
--DELETE
SELECT *
From RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress
--Order by ParcelID



---------------------------------------------------------------------------------------------------

--Delete Unused Columns


Select * 
From NashvilleHousing;


Alter Table NashvilleHousing
DROP column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
DROP column SaleDate
