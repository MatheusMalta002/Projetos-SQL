
---------------------------------------------------------------------------------------------------------


-- 1. Padronizando o formato da data

ALTER TABLE Limpeza.dbo.NashvilleHousing
ALTER COLUMN SaleDate date;


-- [Versão alternativa criando uma nova coluna]

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD SaleDateConverted date;

UPDATE Limpeza.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


---------------------------------------------------------------------------------------------------------


-- 2. Preenchendo os valores nulos na coluna PropertyAddress

-- Executando a consulta abaixo é possível perceber que existem valores  
-- em ParcelID iguais onde alguns tem o valor PropertyAdress e o outros não.

SELECT C1.ParcelID, C1.PropertyAddress, C2.ParcelID, C2.PropertyAddress
FROM Limpeza.dbo.NashvilleHousing C1 INNER JOIN Limpeza.dbo.NashvilleHousing C2 ON (C1.ParcelID = C2.ParcelID)
WHERE  (C1.PropertyAddress IS NULL) AND (C1.[UniqueID ] != C2.[UniqueID ])

-- 1° Se um valor ParcialID tem outra linha com o mesmo parcialID
-- 2° os valores UniqueID dessas linhas são diferentes
-- 3° Uma das linhas com ParcialID iguais posssui o valor NULL em PropertyAddress

-- Isso signifca apenas que a propriedade foi vendida, o dono se altera
-- mas a propriedade permanece no mesmo lugar.

-- Preenchendo os valores NULL com os PropertyAddress das linhas que tem ParcelID iguais

UPDATE C1
SET C1.PropertyAddress = ISNULL(C1.PropertyAddress, C2.PropertyAddress)
FROM Limpeza.dbo.NashvilleHousing C1 
JOIN Limpeza.dbo.NashvilleHousing C2 
	ON (C1.ParcelID = C2.ParcelID) AND (C1.[UniqueID ] != C2.[UniqueID ])
WHERE (C1.PropertyAddress IS NULL) 


---------------------------------------------------------------------------------------------------------


-- 3. Dividindo o endereço em colunas individuais

SELECT SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress)) AS 'Address part 1',
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS 'Address part 2'
FROM Limpeza.dbo.NashvilleHousing

-- Criando novas colunas

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

-- Adicionando as strings quebradas nas colunas

UPDATE Limpeza.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress))

UPDATE Limpeza.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


---------------------------------------------------------------------------------------------------------


-- 4. Dividindo o endereço do proprietário em colunas individuais

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Limpeza.dbo.NashvilleHousing;


ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Limpeza.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Limpeza.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE Limpeza.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------


-- 5. Padronizando os nomes na coluna SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(*)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing
WHERE SoldAsVacant = 'Y';


UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END


---------------------------------------------------------------------------------------------------------


-- 6. Eliminando duplicatas utilizando Common Table Expression

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER( 
		PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY 
		UniqueID ) row_num
FROM Limpeza.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------


-- 7. Apagando colunas não utilizadas

ALTER TABLE  Limpeza.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

select * from NashvilleHousing


---------------------------------------------------------------------------------------------------------

















