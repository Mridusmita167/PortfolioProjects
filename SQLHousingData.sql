
--Cleaning Data in SQL

Select *
From PortfolioProject..[Nashville Housing]


--------------------------------------------------------------------------------------------------
--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..[Nashville Housing]

--Update [Nashville Housing]
--Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing]
Set SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------------
--Populate Property Address Data

Select *
From PortfolioProject..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..[Nashville Housing] a
Join PortfolioProject..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..[Nashville Housing] a
Join PortfolioProject..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

--PropertyAddress

Select PropertyAddress
From PortfolioProject..[Nashville Housing]

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject..[Nashville Housing]

ALTER TABLE [Nashville Housing]
Add Property_Address Nvarchar(255);

Update [Nashville Housing]
Set Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing]
Add Property_City Nvarchar(255);

Update [Nashville Housing]
Set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Select *
--From PortfolioProject..[Nashville Housing]

--Owner Address

Select OwnerAddress 
From PortfolioProject..[Nashville Housing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..[Nashville Housing]

ALTER TABLE [Nashville Housing]
Add Owner_Address Nvarchar(255);

Update [Nashville Housing]
Set Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing]
Add Owner_City Nvarchar(255);

Update [Nashville Housing]
Set Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing]
Add Owner_State Nvarchar(255);

Update [Nashville Housing]
Set Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Select *
--From PortfolioProject..[Nashville Housing]


--------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' Column

Select DISTINCT(SoldAsvacant), COUNT(SoldAsVacant)
From PortfolioProject..[Nashville Housing]
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..[Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From PortfolioProject..[Nashville Housing]
--order by ParcelID
)
--Select *
DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress


--------------------------------------------------------------------------------------------------
--Delete Unused Data

Select *
From PortfolioProject..[Nashville Housing]

ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN SaleDate