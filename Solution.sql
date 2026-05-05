-- George Georgiev --
-- Projet 1 --
USE B44_george;

-- Partie 1 : Modélisation et création --

GO
-- Suppression des tables dans l'ordre inverse des dépendances
DROP TABLE IF EXISTS Relance;
DROP TABLE IF EXISTS Paiement;
DROP TABLE IF EXISTS Facture;
DROP TABLE IF EXISTS Prescription;
DROP TABLE IF EXISTS RendezVous;
DROP TABLE IF EXISTS Medecin;
DROP TABLE IF EXISTS Patient;
GO

CREATE TABLE Patient (
    NoPatient int IDENTITY(1,1) constraint PK_nopatient primary key,
    Nom varchar(50),
    Prenom varchar(50),
    DateNaissance date,
    NoAssurance varchar(20) constraint noAssuranceContrainte unique,
    Maladie varchar(50),
    Telephone varchar(15)
);

CREATE TABLE Medecin (
    NoMedecin int IDENTITY(1,1) constraint PK_nomedecin primary key,
    Nom varchar(50),
    Prenom varchar(50),
    Specialite varchar(100),
    NoPermis varchar(20) constraint permisContrainte unique
);

CREATE TABLE RendezVous (
    NoRendezVous int IDENTITY(1,1) constraint PK_norendezvous primary key,
    NoPatient int constraint FK_nopatientRV foreign key references Patient (NoPatient),
    NoMedecin int constraint FK_nomedecin foreign key references Medecin (NoMedecin),
    DateRV date,
    HeureRV time(7),
    Motif varchar(200) default 'Consultation générale',
    Statut varchar(20) default 'Planifié',
    constraint ck_statutRV check (Statut IN ('Planifié', 'Complété', 'Annulé'))
);

CREATE TABLE Prescription (
    NoPrescription int IDENTITY(1,1) constraint PK_noprescription primary key,
    NoRendezVous int constraint FK_norendezvousP foreign key references RendezVous (NoRendezVous),
    Medicament varchar(100),
    Dosage varchar(50),
    Duree varchar(50),
    DateEmission date default getDate()
);

CREATE TABLE Facture (
    NoFacture int IDENTITY(1,1) constraint PK_nofacture primary key,
    NoRendezVous int constraint FK_norendezvousF foreign key references RendezVous (NoRendezVous),
    NoPatient int constraint FK_nopatientF foreign key references Patient (NoPatient),
    MontantTotal decimal(10, 2),
    constraint ck_montanttotal check (MontantTotal >= 0),
    MontantAssurance decimal(10, 2) default 0,
    constraint ck_montantassurance check (MontantAssurance >= 0), -- Ajusté à >= 0 pour accepter le DEFAULT 0
    MontantDu decimal(10, 2),
    constraint ck_montantduF check (MontantDu >= 0),
    DateFacture date default getDate(),
    Statut varchar (20) default 'Non payé',
    constraint ck_statutF check (Statut IN ('Payé', 'Non payé'))
);

CREATE TABLE Paiement (
    NoPaiement int IDENTITY(1,1) constraint PK_nopaiement primary key,
    NoFacture int constraint FK_nofactureP foreign key references Facture (NoFacture),
    DatePaiement date default getDate(),
    Montant decimal(10, 2),
    constraint ck_montant check (Montant > 0)
);

CREATE TABLE Relance (
    NoRelance int IDENTITY(1,1) constraint PK_norelance primary key,
    NoFacture int constraint FK_nofactureR foreign key references Facture (NoFacture),
    NoPatient int constraint FK_nopatientR foreign key references Patient (NoPatient),
    DateRelance date default getDate(),
    MontantDu decimal(10, 2),
    constraint ck_montantduR check (MontantDu > 0),
    Statut varchar (20) default 'En attente',
    constraint ck_statutR check (Statut IN ('En attente', 'Traitée'))
);
GO

-- Insertion des données (Sans les identifiants)
INSERT INTO Patient (Nom, Prenom, DateNaissance, NoAssurance, Maladie, Telephone) VALUES
('Tremblay', 'Jean', '1980-05-14', 'TREJ12345678', 'Hypertension', '514-555-1234'),
('Gagnon', 'Marie', '1992-08-22', 'GAGM87654321', 'Diabète', '438-555-9876'),
('Roy', 'Paul', '1975-11-02', 'ROYP11223344', 'Asthme', '450-555-4567'),
('Bouchard', 'Sylvie', '1988-03-30', 'BOUS44332211', 'Allergies', '514-555-7890'),
('Gauthier', 'Luc', '2001-07-15', 'GAUL99887766', 'Migraine', '438-555-2468');

INSERT INTO Medecin (Nom, Prenom, Specialite, NoPermis) VALUES
('Cote', 'Alain', 'Médecine générale', 'MD1001'),
('Morin', 'Isabelle', 'Pédiatrie', 'MD1002'),
('Fortin', 'Marc', 'Cardiologie', 'MD1003'),
('Pelletier', 'Sophie', 'Dermatologie', 'MD1004'),
('Bélanger', 'Lucie', 'Psychiatrie', 'MD1005');

INSERT INTO RendezVous (NoPatient, NoMedecin, DateRV, HeureRV, Motif, Statut) VALUES
(1, 1, '2023-10-01', '09:00:00', 'Examen annuel', 'Complété'),
(2, 2, '2023-10-05', '10:30:00', 'Vaccin de routine', 'Complété'),
(3, 3, '2023-10-10', '14:00:00', 'Douleur thoracique', 'Complété'),
(4, 4, '2026-05-20', '11:15:00', 'Éruption cutanée', 'Planifié'),
(5, 1, '2026-06-15', '15:45:00', 'Consultation générale', 'Annulé');

INSERT INTO Prescription (NoRendezVous, Medicament, Dosage, Duree, DateEmission) VALUES
(1, 'Amoxicilline', '500mg', '7 jours', '2023-10-01'),
(2, 'Ibuprofène', '200mg', '3 jours', '2023-10-05'),
(3, 'Aspirine', '81mg', '30 jours', '2023-10-10'),
(1, 'Sirop pour la toux', '10ml', '5 jours', '2023-10-01'),
(3, 'Atorvastatine', '10mg', '90 jours', '2023-10-10');

INSERT INTO Facture (NoRendezVous, NoPatient, MontantTotal, MontantAssurance, MontantDu, DateFacture, Statut) VALUES
(1, 1, 150.00, 100.00, 50.00, '2023-10-01', 'Payé'),
(2, 2, 100.00, 80.00, 20.00, '2023-10-05', 'Payé'),
(3, 3, 250.00, 200.00, 50.00, '2023-10-10', 'Non payé'),
(4, 4, 120.00, 90.00, 30.00, '2026-05-20', 'Non payé'),
(5, 5, 150.00, 120.00, 30.00, '2026-06-15', 'Non payé');

INSERT INTO Paiement (NoFacture, DatePaiement, Montant) VALUES
(1, '2023-10-01', 50.00),
(2, '2023-10-05', 20.00),
(3, '2023-11-01', 25.00),
(4, '2026-05-21', 15.00),
(5, '2026-06-16', 10.00); 

INSERT INTO Relance (NoFacture, NoPatient, DateRelance, MontantDu, Statut) VALUES
(3, 3, '2023-11-10', 25.00, 'Traitée'),
(3, 3, '2023-12-10', 25.00, 'En attente'),
(4, 4, '2026-06-20', 15.00, 'En attente'),
(5, 5, '2026-07-15', 20.00, 'Traitée'),
(4, 4, '2026-07-20', 15.00, 'En attente');
GO

select * from Patient;
select * from Medecin;
select * from RendezVous;
select * from Prescription;
select * from Facture;
select * from Paiement;
select * from Relance;

-- Partie 2 --

-- 1. Lister tous les rendez-vous d'un médecin pour une journée donnée
SELECT 
    NoRendezVous, 
    HeureRV, 
    P.Nom + ' ' + P.Prenom AS 'Patient', 
    Motif, 
    Statut
FROM RendezVous RV
INNER JOIN Patient P ON RV.NoPatient = P.NoPatient
WHERE RV.NoMedecin = 1 AND RV.DateRV = '2023-10-01';

-- 2. Afficher les patients ayant des factures impayées
SELECT 
    P.NoPatient, 
    P.Nom + ' ' + P.Prenom AS 'Patient', 
    Telephone, 
    MontantDu AS 'TotalDu'
FROM Patient P
INNER JOIN Facture F ON P.NoPatient = F.NoPatient
WHERE F.Statut = 'Non payé';

-- 3. Calculer le nombre moyen de rendez-vous par médecin
SELECT CAST(AVG(NbRendezVous * 1.0) AS DECIMAL(10, 6)) AS 'MoyenneRendezVousParMedecin'
FROM (
    SELECT COUNT(RV.NoRendezVous) AS NbRendezVous
    FROM Medecin M
    LEFT JOIN RendezVous RV ON M.NoMedecin = RV.NoMedecin
    GROUP BY M.NoMedecin
) AS SousRequete;

-- 4. Trouver les 5 médecins ayant vu le plus de patients distincts
SELECT TOP 5 Nom + ' ' + Prenom AS 'Medecin', Specialite, COUNT(DISTINCT RV.NoPatient) AS 'NbPatientsDistincts'
FROM Medecin M
INNER JOIN RendezVous RV ON M.NoMedecin = RV.NoMedecin
GROUP BY M.NoMedecin, Prenom, Nom, Specialite
ORDER BY COUNT(DISTINCT RV.NoPatient) DESC;

-- 5. Lister tous les rendez-vous annulés au cours des 30 derniers jours
SELECT 
    NoRendezVous AS 'No Rendez Vous', 
    DateRV, 
    HeureRV AS 'Heure RV', 
    P.Nom + ' ' + P.Prenom AS 'Patient', 
    M.Nom + ' ' + M.Prenom AS 'Medecin', 
    Motif
FROM RendezVous RV
INNER JOIN Patient P ON RV.NoPatient = P.NoPatient
INNER JOIN Medecin M ON RV.NoMedecin = M.NoMedecin
WHERE RV.Statut = 'Annulé' AND RV.DateRV >= DATEADD(DAY, -30, GETDATE());


-- Partie 3 --

-- 1.sp_PrendreRendezVous (sans valeur de retour) : enregistre un nouveau rendez-vous 
-- en vérifiant qu'il n'y a pas de conflit d'horaire pour le médecin.
-- Utilise une valeur de défaut pour le motif (avec gestion d'erreurs TRY/CATCH)
GO
IF OBJECT_ID('dbo.sp_PrendreRendezVous') IS NOT NULL
    DROP PROCEDURE sp_PrendreRendezVous 
GO

CREATE PROCEDURE sp_PrendreRendezVous 
    @NoPatient INT,
    @NoMedecin INT,
    @DateRV DATE,
    @HeureRV TIME(7),
    @Motif VARCHAR(200) = 'Consultation générale' 
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
            SELECT 1 
            FROM RendezVous 
            WHERE NoMedecin = @NoMedecin 
              AND DateRV = @DateRV 
              AND HeureRV = @HeureRV
              AND Statut != 'Annulé'
        )
        BEGIN
            THROW 50000, 'Conflit d''horaire', 1; 
        END
        
        INSERT INTO RendezVous (NoPatient, NoMedecin, DateRV, HeureRV, Motif, Statut)
        VALUES (@NoPatient, @NoMedecin, @DateRV, @HeureRV, @Motif, 'Planifié');

        PRINT 'Rendez-vous créé avec succès.';

    END TRY
    BEGIN CATCH
        PRINT 'ERREUR: Ce médecin a déjà un rendez-vous à cette heure.';
    END CATCH
END
GO

-- 2. sp_CompleterRendezVous (sans valeur de retour) : marque le rendez-vous comme complété, 
-- génère une prescription si nécessaire et crée la facture associée.
-- Appeler votre procédure et afficher selon le format
-- « Rendez-vous complété et facture créée avec succès. » ou
-- « ERREUR : Rendez-vous introuvable ou déjà traité. »
GO
IF OBJECT_ID('dbo.sp_CompleterRendezVous') IS NOT NULL
    DROP PROCEDURE sp_CompleterRendezVous
GO

CREATE PROCEDURE sp_CompleterRendezVous 
    @NoRendezVous INT,
    @MontantTotal DECIMAL(10, 2),
    @MontantAssurance DECIMAL(10, 2) = 0,
    @Medicament VARCHAR(100) = NULL,
    @Dosage VARCHAR(50) = NULL,
    @Duree VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM RendezVous 
            WHERE NoRendezVous = @NoRendezVous 
              AND Statut = 'Planifié'
        )

        BEGIN
            THROW 50000, 'Rendez-vous introuvable ou déjà traité', 1; 
        END

        UPDATE RendezVous
        SET Statut = 'Complété'
        WHERE NoRendezVous = @NoRendezVous;

        IF @Medicament IS NOT NULL
        BEGIN
            INSERT INTO Prescription (NoRendezVous, Medicament, Dosage, Duree)
            VALUES (@NoRendezVous, @Medicament, @Dosage, @Duree);
        END

        DECLARE @NoPatient INT;
        SELECT @NoPatient = NoPatient FROM RendezVous WHERE NoRendezVous = @NoRendezVous;

        DECLARE @MontantDu DECIMAL(10, 2) = @MontantTotal - @MontantAssurance;

        INSERT INTO Facture (NoRendezVous, NoPatient, MontantTotal, MontantAssurance, MontantDu, Statut)
            VALUES (@NoRendezVous, @NoPatient, @MontantTotal, @MontantAssurance, @MontantDu, 'Non payé');

        PRINT 'Rendez-vous complété et facture créée avec succès.';

    END TRY
    BEGIN CATCH
        PRINT 'ERREUR : Rendez-vous introuvable ou déjà traité.';
    END CATCH
END
GO

-- 3. sp_StatistiquesPatient (avec 2 paramètres OUTPUT) : reçoit un numéro de patient 
-- et retourne via des paramètres de sortie le nombre total de rendez-vous 
-- et le montant total dû pour ce patient.
GO
IF OBJECT_ID('dbo.sp_StatistiquesPatient') IS NOT NULL
    DROP PROCEDURE sp_StatistiquesPatient
GO
    CREATE PROCEDURE sp_StatistiquesPatient
        @NoPatient INT,
        @NombreRendezVous INT OUTPUT,
        @MontantTotalDû DECIMAL(10, 2) OUTPUT
        AS 
    BEGIN
        BEGIN TRY (
        
        
        )