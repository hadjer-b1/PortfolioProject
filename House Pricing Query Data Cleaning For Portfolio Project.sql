/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData

-- Standardize Data format

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousingData


-- In case we want it the date to look shorter (Sometime they add hh:mm:ss to the date )
-- We use:

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

-- But if we want to preserve the column while having adjusted version we can just add a new column 

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------

SELECT SaleDate, SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData


--__--__--__--__--__----__--__--__--__--__----__--__--__--__--__----__--__--__--__--__--


--Popuplate Property Address Data


SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID , a.PropertyAddress, 
       b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
     ON a.ParcelID = b.ParcelID
     AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
     ON a.ParcelID = b.ParcelID
     AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


--__--__--__--__--__----__--__--__--__--__----__--__--__--__--__----__--__--__--__--__--

-- ----- Breaking out Adress into Individual Columns (Addrss, City, State) -------

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData
 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City 
FROM PortfolioProject.dbo.NashvilleHousingData


-- Adding a column For the Address

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertySplitedAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


-- Adding a column For the City

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertySplitedCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))  

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData


-------------------------------------------------------------------------------------------------------------

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 1),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitedAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitedAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)



ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitedCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitedCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitedState Nvarchar(20);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitedState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData



--__--__--__--__--__----__--__--__--__--__----__--__--__--__--__----__--__--__--__--__--

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant


SELECT SoldAsVacant ,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
        END
FROM PortfolioProject.dbo.NashvilleHousingData


UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                    END

--__--__--__--__--__----__--__--__--__--__----__--__--__--__--__----__--__--__--__--__--

-- Remove Duplicates:
WITH RowNumCTE AS(
SELECT * ,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
                       UniqueID
                       ) row_num
FROM PortfolioProject.dbo.NashvilleHousingData
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousingData


--__--__--__--__--__----__--__--__--__--__----__--__--__--__--__----__--__--__--__--__--

-- Delete Unused Columns
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousingData


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress

--__--__--__--__--__----__--__--__--__--__----__--__--__--__--__----__--__--__--__--__--












