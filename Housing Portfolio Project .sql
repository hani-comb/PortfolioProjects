/*
Cleaning Data in SQL Queries
*/
SELECT *
FROM   portfolioproject.dbo.nashvillehousing
--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date FormatSELECT saledateconverted,
       CONVERT(DATE,saledate)
FROM   portfolioproject.dbo.nashvillehousingUPDATE nashvillehousing
SET    saledate = CONVERT(DATE,saledate)
-- If it doesn't Update properlyALTER TABLE nashvillehousing ADD saledateconverted DATE;UPDATE nashvillehousing
SET    saledateconverted = CONVERT(DATE,saledate)
--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address dataSELECT   *
FROM     portfolioproject.dbo.nashvillehousing
         --Where PropertyAddress is null
ORDER BY parcelidSELECT a.parcelid,
       a.propertyaddress,
       b.parcelid,
       b.propertyaddress,
       Isnull(a.propertyaddress,b.propertyaddress)
FROM   portfolioproject.dbo.nashvillehousing a
JOIN   portfolioproject.dbo.nashvillehousing b
ON     a.parcelid = b.parcelid
AND    a.[uniqueid] <> b.[uniqueid]
WHERE  a.propertyaddress IS NULLUPDATE a
SET    PropertyAddress = Isnull(a.propertyaddress,b.propertyaddress)
FROM   portfolioproject.dbo.nashvillehousing a
JOIN   portfolioproject.dbo.nashvillehousing b
ON     a.parcelid = b.parcelid
AND    a.[uniqueid] <> b.[uniqueid]
WHERE  a.propertyaddress IS NULL
--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)SELECT propertyaddress
FROM   portfolioproject.dbo.nashvillehousing
--Where PropertyAddress is null
--order by ParcelIDSELECT Substring(propertyaddress, 1, Charindex(',', propertyaddress) -1 )                     AS Address ,
       Substring(propertyaddress, Charindex(',', propertyaddress) + 1 , Len(propertyaddress)) AS Address
FROM   portfolioproject.dbo.nashvillehousingALTER TABLE nashvillehousing ADD propertysplitaddress NVARCHAR(255);UPDATE nashvillehousing
SET    propertysplitaddress = Substring(propertyaddress, 1, Charindex(',', propertyaddress) -1 )ALTER TABLE nashvillehousing ADD propertysplitcity NVARCHAR(255);UPDATE nashvillehousing
SET    propertysplitcity = Substring(propertyaddress, Charindex(',', propertyaddress) + 1 , Len(propertyaddress))SELECT *
FROM   portfolioproject.dbo.nashvillehousingSELECT owneraddress
FROM   portfolioproject.dbo.nashvillehousingSELECT Parsename(Replace(owneraddress, ',', '.') , 3) ,
       Parsename(Replace(owneraddress, ',', '.') , 2) ,
       Parsename(Replace(owneraddress, ',', '.') , 1)
FROM   portfolioproject.dbo.nashvillehousingALTER TABLE nashvillehousing ADD ownersplitaddress NVARCHAR(255);UPDATE nashvillehousing
SET    ownersplitaddress = Parsename(Replace(owneraddress, ',', '.') , 3)ALTER TABLE nashvillehousing ADD ownersplitcity NVARCHAR(255);UPDATE nashvillehousing
SET    ownersplitcity = Parsename(Replace(owneraddress, ',', '.') , 2)ALTER TABLE nashvillehousing ADD ownersplitstate NVARCHAR(255);UPDATE nashvillehousing
SET    ownersplitstate = Parsename(Replace(owneraddress, ',', '.') , 1)SELECT *
FROM   portfolioproject.dbo.nashvillehousing
--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" fieldSELECT DISTINCT(soldasvacant),
                Count(soldasvacant)
FROM            portfolioproject.dbo.nashvillehousing
GROUP BY        soldasvacant
ORDER BY        2SELECT soldasvacant ,
       CASE
              WHEN soldasvacant = 'Y' THEN 'Yes'
              WHEN soldasvacant = 'N' THEN 'No'
              ELSE soldasvacant
       END
FROM   portfolioproject.dbo.nashvillehousingUPDATE nashvillehousing
SET    soldasvacant =
       CASE
              WHEN soldasvacant = 'Y' THEN 'Yes'
              WHEN soldasvacant = 'N' THEN 'No'
              ELSE soldasvacant
       END
       -----------------------------------------------------------------------------------------------------------------------------------------------------------
       -- Remove Duplicates
       with rownumcte AS
       (
                SELECT   *,
                         row_number() OVER ( partition BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid ) row_num
                FROM     portfolioproject.dbo.nashvillehousing
                         --order by ParcelID
       )SELECT   *
FROM     rownumcte
WHERE    row_num > 1
ORDER BY propertyaddressSELECT *
FROM   portfolioproject.dbo.nashvillehousing
---------------------------------------------------------------------------------------------------------
-- Delete Unused ColumnsSELECT *
FROM   portfolioproject.dbo.nashvillehousingALTER TABLE portfolioproject.dbo.nashvillehousing DROP COLUMN owneraddress,
            taxdistrict,
            propertyaddress,
            saledate
            -----------------------------------------------------------------------------------------------
            -----------------------------------------------------------------------------------------------
            --- Importing Data using OPENROWSET and BULK INSERT
            --  More advanced and looks cooler, but have to configure server appropriately to do correctly
            --  Wanted to provide this in case you wanted to try it
            --sp_configure 'show advanced options', 1;
            --RECONFIGURE;
            --GO
            --sp_configure 'Ad Hoc Distributed Queries', 1;
            --RECONFIGURE;
            --GO
            --USE PortfolioProject
            --GO
            --EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
            --GO
            --EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
            --GO
            ---- Using BULK INSERT
            --USE PortfolioProject;
            --GO
            --BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
            --   WITH (
            --      FIELDTERMINATOR = ',',
            --      ROWTERMINATOR = '\n'
            --);
            --GO
            ---- Using OPENROWSET
            --USE PortfolioProject;
            --GO
            --SELECT * INTO nashvilleHousing
            --FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
            --    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
            --GO