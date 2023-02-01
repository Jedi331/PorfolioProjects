/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PorfolioProject].[dbo].[NashvilleHousing]

  /*
  Cleaning Data in SQL QUERIES

  */

  Select * from PorfolioProject.dbo.NashvilleHousing

 ----------------------------------------------------------------------------------

 --Standardize Date Format


  Select saleDateConverted, CONVERT (Date, SaleDate)
  from PorfolioProject.dbo.NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = CONVERT (Date, SaleDate)

  ALTER TABLE NashvilleHousing
  ADD SaleDateConverted DATE;
  
  UPDATE NashvilleHousing
  SET SaleDateConverted = CONVERT (Date, Saledate)



    ------------------------------------------------------------------------------

--Populate Property Address data

Select *
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL




---------------------------------------------------------------------------------


--Breaking out Address into individual Columns (Address, City, States)


Select *
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PorfolioProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress NvarChar(255);
  
UPDATE NashvilleHousing
  SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
  ADD PropertySplitCity NvarChar(255);
  
UPDATE NashvilleHousing
  SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





Select *
from PorfolioProject.dbo.NashvilleHousing







Select OwnerAddress
from PorfolioProject.dbo.NashvilleHousing




Select 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress NvarChar(255);
  
UPDATE NashvilleHousing
  SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity NvarChar(255);
  
UPDATE NashvilleHousing
  SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)


  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState NvarChar(255);
  
UPDATE NashvilleHousing
  SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)







----------------------------------------------------------------------------------------------


--Change Y and N into Yes and No in "Sold as Vacant" field



Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from PorfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2





Select SoldasVacant
, Case when SoldasVacant = 'Y' Then 'Yes'
	   when SoldasVacant = 'N' Then 'No'
	   Else SoldasVacant
	   END
from PorfolioProject.dbo.NashvilleHousing



UPDATE NashvilleHousing
Set SoldAsVacant = Case when SoldasVacant = 'Y' Then 'Yes'
	   when SoldasVacant = 'N' Then 'No'
	   Else SoldasVacant
	   END


------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID) row_num

from PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
Where row_num>1
Order by PropertyAddress


------------------------------------------------------------------------------------------

--Delete Unused Columns


ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
from PorfolioProject.dbo.NashvilleHousing