﻿DROP TABLE IF EXISTS `yafnet`.`reviews`;
DROP TABLE IF EXISTS `yafnet`.`associatedkeywords`;
DROP TABLE IF EXISTS `yafnet`.`contentobjects`;
DROP TABLE IF EXISTS `yafnet`.`keywords`;
CREATE TABLE  `yafnet`.`contentobjects` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Description` varchar(400) NOT NULL DEFAULT ' ',
  `Title` varchar(400) NOT NULL DEFAULT ' ',
  `ContentFileName` varchar(400) NOT NULL DEFAULT ' ',
  `ContentFileId` varchar(400) NOT NULL DEFAULT ' ',
  `ScreenShotFileName` varchar(400) NOT NULL DEFAULT ' ',
  `ScreenShotFileId` varchar(400) NOT NULL DEFAULT ' ',
  `Submitter` varchar(400) NOT NULL DEFAULT ' ',
  `SponsorLogoFileName` varchar(400) NOT NULL DEFAULT ' ',
  `SponsorLogoFileId` varchar(400) NOT NULL DEFAULT ' ',
  `DeveloperLogoFileName` varchar(400) NOT NULL DEFAULT ' ',
  `DeveloperLogoFileId` varchar(400) NOT NULL DEFAULT ' ',
  `AssetType` varchar(400) NOT NULL DEFAULT ' ',
  `DisplayFileName` varchar(400) NOT NULL DEFAULT ' ',
  `DisplayFileId` varchar(400) NOT NULL DEFAULT ' ',
  `MoreInfoUrl` varchar(400) NOT NULL DEFAULT ' ',
  `DeveloperName` varchar(400) NOT NULL DEFAULT ' ',
  `SponsorName` varchar(400) NOT NULL DEFAULT ' ',
  `ArtistName` varchar(400) NOT NULL DEFAULT ' ',
  `CreativeCommonsLicenseUrl` varchar(400) NOT NULL DEFAULT ' ',
  `UnitScale` varchar(400) NOT NULL DEFAULT ' ',
  `UpAxis` varchar(400) NOT NULL DEFAULT ' ',
  `UVCoordinateChannel` varchar(400) NOT NULL DEFAULT ' ',
  `IntentionOfTexture` varchar(400) NOT NULL DEFAULT ' ',
  `Format` varchar(400) NOT NULL DEFAULT ' ',
  `Views` int(10) unsigned zerofill NOT NULL DEFAULT '0000000000',
  `Downloads` int(10) unsigned zerofill NOT NULL DEFAULT '0000000000',
  `NumPolygons` int(10) unsigned zerofill NOT NULL DEFAULT '0000000000',
  `NumTextures` int(10) unsigned zerofill NOT NULL DEFAULT '0000000000',
  `UploadedDate` datetime DEFAULT '0000-00-00 00:00:00',
  `LastModified` datetime DEFAULT '0000-00-00 00:00:00',
  `LastViewed` datetime DEFAULT '0000-00-00 00:00:00',
  `PID` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_contentobjects_1` (`Submitter`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

CREATE TABLE  `yafnet`.`keywords` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Keyword` varchar(45) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  `yafnet`.`associatedkeywords` (
  `ContentObjectId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `KeywordId` int(10) unsigned NOT NULL,
  KEY `FK_AssociatedKeywords_1` (`ContentObjectId`),
  KEY `FK_associatedkeywords_2` (`KeywordId`),
  CONSTRAINT `FK_AssociatedKeywords_1` FOREIGN KEY (`ContentObjectId`) REFERENCES `contentobjects` (`ID`),
  CONSTRAINT `FK_associatedkeywords_2` FOREIGN KEY (`KeywordId`) REFERENCES `keywords` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  `yafnet`.`reviews` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Rating` int(10) unsigned NOT NULL,
  `Text` varchar(45) NOT NULL,
  `SubmittedBy` varchar(45) NOT NULL,
  `SubmittedDate` datetime NOT NULL,
  `ContentObjectId` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_Reviews_1` (`ContentObjectId`),
  KEY `FK_reviews_2` (`SubmittedBy`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetAllContentObjects`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetAllContentObjects`()
BEGIN
  SELECT *
  FROM `contentobjects`;
END $$

DELIMITER ;
DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetContentObject`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetContentObject`(targetpid varchar(400))
BEGIN
  SELECT *
  FROM `contentobjects`
  WHERE pid = targetpid;
END $$

DELIMITER ;
DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetHighestRated`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetHighestRated`(s integer, length integer)
BEGIN
SET @lmt = length;
SET @s = s;
PREPARE STMT FROM "SELECT PID, Title, ScreenShotFileName,ScreenShotFileId
FROM ContentObjects
LEFT JOIN Reviews
ON ContentObjects.PID = Reviews.ContentObjectId
GROUP BY ContentObjects.PID
ORDER BY AVG(Reviews.Rating) DESC
LIMIT ?,?";
EXECUTE STMT USING @s, @lmt;
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetMostPopularContentObjects`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetMostPopularContentObjects`()
BEGIN
    SELECT PID, Title, ScreenShotFileName,ScreenShotFileId
    FROM ContentObjects
    ORDER BY Views;
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetMostRecentlyUpdated`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetMostRecentlyUpdated`(s integer, length integer)
BEGIN
    SET @lmt = length;
    set @s = s;
    PREPARE STMT FROM "SELECT PID, Title, ScreenShotFileName,ScreenShotFileId
    FROM ContentObjects
    ORDER BY LastModified DESC LIMIT ?,?";
    EXECUTE STMT USING @s, @lmt;
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetMostRecentlyViewed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetMostRecentlyViewed`(s integer, length integer)
BEGIN
    SET @s = s;
    set @lmt = length;
    PREPARE STMT FROM "SELECT PID, Title, ScreenShotFileName,ScreenShotFileId
    FROM ContentObjects
    ORDER BY LastViewed DESC
    LIMIT ?,?";
    EXECUTE STMT USING @s, @lmt;
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`GetReviews`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`GetReviews`(pid varchar(400))
BEGIN
        SELECT *
        FROM `yafnet`.`reviews`
        WHERE ContentObjectId = pid;
END $$

DELIMITER ;
DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`IncrementViews`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`IncrementViews`(targetpid varchar(400))
BEGIN
        UPDATE ContentObjects SET Views = Views+1, LastViewed=NOW()
        WHERE PID =targetpid;
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`InsertContentObject`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`InsertContentObject`(newpid nvarchar(400),
newtitle nvarchar(400),
newcontentfilename nvarchar(400),
newcontentfileid nvarchar(400),
newsubmitter nvarchar(400),
newcreativecommonslicenseurl nvarchar(400),
newdescription nvarchar(400),
newscreenshotfilename nvarchar(400),
newscreenshotfileid nvarchar(400),
newsponsorlogofilename nvarchar(400),
newsponsorlogofileid nvarchar(400),
newdeveloperlogofilename nvarchar(400),
newdeveloperlogofileid nvarchar(400),
newassettype nvarchar(400),
newdisplayfilename nvarchar(400),
newdisplayfileid nvarchar(400),
newmoreinfourl nvarchar(400),
newdevelopername nvarchar(400),
newsponsorname nvarchar(400),
newartistname nvarchar(400),
newunitscale nvarchar(400),
newupaxis nvarchar(400),
newuvcoordinatechannel nvarchar(400),
newintentionoftexture nvarchar(400),
newformat nvarchar(400))
BEGIN
INSERT INTO `yafnet`.`ContentObjects` (pid,
title,
contentfilename,
contentfileid,
submitter,
creativecommonslicenseurl,
description,
screenshotfilename,
screenshotfileid,
sponsorlogofilename,
sponsorlogofileid,
developerlogofilename,
developerlogofileid,
assettype,
displayfilename,
displayfileid,
moreinfourl,
developername,
sponsorname,
artistname,
unitscale,
upaxis,
uvcoordinatechannel,
intentionoftexture,
format)
values (newpid,
newtitle,
newcontentfilename,
newcontentfileid,
newsubmitter,
newcreativecommonslicenseurl,
newdescription,
newscreenshotfilename,
screenshotfileid,
newsponsorlogofilename,
newsponsorlogofileid,
newdeveloperlogofilename,
newdeveloperlogofileid,
newassettype,
newdisplayfilename,
newdisplayfileid,
newmoreinfourl,
newdevelopername,
newsponsorname,
newartistname,
newunitscale,
newupaxis,
newuvcoordinatechannel,
newintentionoftexture,
newformat);
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`InsertReview`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`InsertReview`(newrating int(10),
newtext varchar(45),newsubmittedby varchar(45),newcontentobjectid varchar(400))
BEGIN
      INSERT INTO `yafnet`.`reviews`(rating,
      text,submittedby,contentobjectid,SubmittedDate)
      values(newrating,newtext,newsubmittedby,newcontentobjectid, NOW());
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `yafnet`.`UpdateContentObject`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `yafnet`.`UpdateContentObject`(newpid nvarchar(400),
newtitle nvarchar(400),
newcontentfilename nvarchar(400),
newcontentfileid nvarchar(400),
newsubmitter nvarchar(400),
newcreativecommonslicenseurl nvarchar(400),
newdescription nvarchar(400),
newscreenshotfilename nvarchar(400),
newscreenshotfileid nvarchar(400),
newsponsorlogofilename nvarchar(400),
newsponsorlogofileid nvarchar(400),
newdeveloperlogofilename nvarchar(400),
newdeveloperlogofileid nvarchar(400),
newassettype nvarchar(400),
newdisplayfilename nvarchar(400),
newdisplayfileid nvarchar(400),
newmoreinfourl nvarchar(400),
newdevelopername nvarchar(400),
newsponsorname nvarchar(400),
newartistname nvarchar(400),
newunitscale nvarchar(400),
newupaxis nvarchar(400),
newuvcoordinatechannel nvarchar(400),
newintentionoftexture nvarchar(400),
newformat nvarchar(400))
BEGIN
UPDATE `yafnet`.`ContentObjects`
SET title = newtitle,
contentfilename = newcontentfilename,
contentfileid = newcontentfileid,
submitter = newsubmitter,
creativecommonslicenseurl = newcreativecommonslicenseurl,
description = newdescription,
screenshotfilename = newscreenshotfilename,
screenshotfileid = newscreenshotfileid,
sponsorlogofilename = newsponsorlogofilename,
sponsorlogofileid = newsponsorlogofileid,
developerlogofilename = newdeveloperlogofilename,
developerlogofileid = newdeveloperlogofileid,
assettype = newassettype,
displayfilename = newdisplayfilename,
displayfileid = newdisplayfileid,
moreinfourl = newmoreinfourl,
developername = newdevelopername,
sponsorname = newsponsorname,
artistname = newartistname,
unitscale = newunitscale,
upaxis = newupaxis,
uvcoordinatechannel = newuvcoordinatechannel,
intentionoftexture = newintentionoftexture,
LastModified = NOW(),
format = newformat
WHERE pid=newpid;
END $$

DELIMITER ;