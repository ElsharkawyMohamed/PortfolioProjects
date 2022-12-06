/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------------


-- Standardize Date Formate


Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Alter Table Nashvillehousing
Add SaleDateConverted Date;


Update Nashvillehousing
SET SaleDateConverted = Convert(Date,SaleDate)


Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing


--Where PropertyAddress is null


order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 Where a.PropertyAddress is null
-----------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


--PropertyAddress


Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


Alter Table Nashvillehousing
Add PropertySplitAddress Nvarchar(225);


Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1 )


Alter Table Nashvillehousing
Add PropertySplitCity Nvarchar(225);


Update Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEn(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


--OwnerAddress


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


Alter Table Nashvillehousing
Add OwnerSplitAddress Nvarchar(225);


Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table Nashvillehousing
Add OwnerSplitCity Nvarchar(225);


Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter Table Nashvillehousing
Add OwnerSplitState Nvarchar(225);


Update Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
-----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field


Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
-----------------------------------------------------------------------------------------

-- Remove Duplicates


With RowNumCTE AS(
Select *,
    ROW_NUMBER() Over (
    PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 UniqueID
			 ) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
where row_num > 1
-----------------------------------------------------------------------------------------

--Order by PropertyAddress


-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
