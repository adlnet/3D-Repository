﻿using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using System.IO;
using System.Diagnostics;
using vwarDAL;


public partial class Controls_Upload : System.Web.UI.UserControl
{
    //TODO: remove - testing only
    private bool containsValidTextureFile = true;

    protected bool IsNew
    {
        get
        {
            bool rv = string.IsNullOrEmpty(this.ContentObjectID);

            return rv ;
        }
        
    }

    private bool IsModelUpload
    {
        get
        {
            return ddlAssetType.SelectedValue.Equals("Model", StringComparison.InvariantCultureIgnoreCase);
        }
    }

    protected string ContentObjectID
    {
        get
        {
            string rv = "";
            if (Request.QueryString["ContentObjectID"] != null)
            {
                rv = Request.QueryString["ContentObjectID"].Trim();
            }
            else if (ViewState["ContentObjectID"] != null)
            {
                rv = ViewState["ContentObjectID"].ToString();
            }

            return rv;
        }
        set { ViewState["ContentObjectID"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.Page.Master.FindControl("SearchPanel") != null)
        {
            //hide the search panel
            this.Page.Master.FindControl("SearchPanel").Visible = false;
        }

        //redirect if user is not authenticated
        if (!Context.User.Identity.IsAuthenticated)
        {
            Response.Redirect("~/Default.aspx");
        }

        if (!Page.IsPostBack)
        {
            
            this.MultiView1.ActiveViewIndex = 0;        
            this.BindCCLHyperLink();
            this.BindContentObject();

            

        }



    }

    private void BindContentObject()
    {
               
        if (!this.IsNew)
        {
            //update
            
            //current
            var factory = new vwarDAL.DataAccessFactory();
            vwarDAL.IDataRepository vd = factory.CreateDataRepositorProxy();
            var co = vd.GetContentObjectById(this.ContentObjectID, false);

            if (co != null)
            {
                
                //remove the required field validators for model and thumbnail = false
                this.ContentFileUploadRequiredFieldValidator.Enabled = false;
                this.ThumbnailFileUploadRequiredFieldValidator.Enabled = false;


                //redirect if the user is not the owner
                if (!co.SubmitterEmail.Equals(Context.User.Identity.Name, StringComparison.InvariantCultureIgnoreCase) & !Website.Security.IsAdministrator())
                {
                    Response.Redirect("~/Default.aspx");
                    return;
                }

                //Asset Type
                if (!string.IsNullOrEmpty(co.AssetType))
                {
                    //set selected
                    if (this.ddlAssetType.SelectedItem != null)
                    {
                        this.ddlAssetType.ClearSelection();
                    }

                    this.ddlAssetType.Items.FindByValue(co.AssetType.Trim()).Selected = true;   

                }
                

                //Title
                if (!string.IsNullOrEmpty(co.Title))
                {
                    this.TitleTextBox.Text = co.Title.Trim();
                }

                //Developer name
                if (!string.IsNullOrEmpty(co.DeveloperName))
                {
                    this.DeveloperNameTextBox.Text = co.DeveloperName.Trim();
                }


                //Bind Developer Logo / Sponsor Logo
                UserProfile p = null;

                if (Context.User.Identity.IsAuthenticated)
                {
                    try
                    {
                        p = UserProfileDB.GetUserProfileByUserName(Context.User.Identity.Name);
                    }
                    catch
                    {


                    }
                }

                //Developer Logo
                this.BindDeveloperLogo(co, p);

                //sponsor logo
                this.BindSponsorLogo(co, p);


                //Sponsor Name
                if (!string.IsNullOrEmpty(co.SponsorName))
                {
                    this.SponsorNameTextBox.Text = co.SponsorName.Trim();
                }

                //Artist Name
                if (!string.IsNullOrEmpty(co.ArtistName))
                {
                    this.ArtistNameTextBox.Text = co.ArtistName.Trim();
                }


                //CC License
                if (!string.IsNullOrEmpty(co.CreativeCommonsLicenseURL))
                {


                    //set selected
                    if (this.CCLicenseDropDownList.Items.FindByValue(co.CreativeCommonsLicenseURL) != null)
                    {
                        //clear selection
                        if (this.CCLicenseDropDownList.SelectedItem != null)
                        {
                            this.CCLicenseDropDownList.ClearSelection();
                        }

                        this.CCLicenseDropDownList.Items.FindByValue(co.CreativeCommonsLicenseURL).Selected = true;
                    }

                    //set the hyperlink
                    this.CCLHyperLink.NavigateUrl = co.CreativeCommonsLicenseURL.Trim();
                }
                else
                {
                    //set none selected
                    if (this.CCLicenseDropDownList.SelectedItem != null)
                    {
                        this.CCLicenseDropDownList.ClearSelection();
                    }

                    this.CCLicenseDropDownList.Items.FindByValue("None").Selected = true;


                }



                //Description
                if (!string.IsNullOrEmpty(co.Description))
                {
                    this.DescriptionTextBox.Text = co.Description.Trim();

                }

                //More Information
                if (!string.IsNullOrEmpty(co.MoreInformationURL))
                {
                    this.MoreInformationURLTextBox.Text = co.MoreInformationURL.Trim();

                }

                //Keywords
                if (!string.IsNullOrEmpty(co.Keywords.Trim()))
                {
                    this.KeywordsTextBox.Text = co.Keywords.Trim();
                }


                //Unit Scale
                if (!string.IsNullOrEmpty(co.UnitScale))
                {
                    this.UnitScaleTextBox.Text = co.UnitScale.Trim();
                }

                //Up Axis
                if (!string.IsNullOrEmpty(co.UpAxis))
                {
                    this.UpAxisRadioButtonList.ClearSelection();

                    if (this.UpAxisRadioButtonList.Items.FindByText(co.UpAxis) != null)
                    {
                        this.UpAxisRadioButtonList.Items.FindByText(co.UpAxis).Selected = true;
                    }


                }

                //NumPolygons
                if (!string.IsNullOrEmpty(co.NumPolygons.ToString()))
                {
                    this.NumPolygonsTextBox.Text = co.NumPolygons.ToString();
                }

                //NumTextures
                if (!string.IsNullOrEmpty(co.NumTextures.ToString()))
                {
                    this.NumTexturesTextBox.Text = co.NumTextures.ToString();
                }

                //UV Coordinate Channel
                if (!string.IsNullOrEmpty(co.UVCoordinateChannel))
                {
                    this.UVCoordinateChannelTextBox.Text = co.UVCoordinateChannel.Trim();
                }

                //Intention of Texture
                if (!string.IsNullOrEmpty(co.IntentionOfTexture))
                {
                    this.IntentionofTextureTextBox.Text = co.IntentionOfTexture.Trim();
                }


            }
            else
            {



                //Show error message
                this.errorMessage.Text = "Model not found.";

            }




        }
        else
        {

            //new
            this.ContentFileUploadRequiredFieldValidator.Enabled = true;
            this.ThumbnailFileUploadRequiredFieldValidator.Enabled = true;



            UserProfile p = null;

            if (Context.User.Identity.IsAuthenticated)
            {
                try
                {
                    p = UserProfileDB.GetUserProfileByUserName(Context.User.Identity.Name);
                }
                catch
                {


                }
            }


         
            //Developer Logo
            this.BindDeveloperLogo(null, p);

            //sponsor logo
            this.BindSponsorLogo(null, p);

        }





    }

    protected void Step1NextButton_Click(object sender, EventArgs e)
    {

        var factory = new vwarDAL.DataAccessFactory();
        vwarDAL.IDataRepository dal = factory.CreateDataRepositorProxy();
        ContentObject contentObj = null;
        
        if (!this.IsNew)
        {
            contentObj = dal.GetContentObjectById(ContentObjectID, false);
           
            if (contentObj == null)
            {
                //show error message
                this.errorMessage.Text = "Model not found.";
                this.MultiView1.SetActiveView(this.DefaultView);
                return;
            }
            





        }
        else
        {
            contentObj = new vwarDAL.ContentObject();

        }

        contentObj.AssetType = this.ddlAssetType.SelectedValue;

        //required fields
        contentObj.Title = this.TitleTextBox.Text.Trim();


        if (!string.IsNullOrEmpty(this.ContentFileUpload.FileName))
        {
            contentObj.Location = this.ContentFileUpload.FileName.Trim();
        }
      
       
        
        if(!string.IsNullOrEmpty(this.ContentFileUpload.FileName.ToString()))
        {
            contentObj.ScreenShot = this.ThumbnailFileUpload.FileName.Trim();
        }

        

        //optional fields

        //developer name
        if (!string.IsNullOrEmpty(this.DeveloperNameTextBox.Text.Trim()))
        {
            contentObj.DeveloperName = this.DeveloperNameTextBox.Text.Trim();
        }

        //sponsor name
        if (!string.IsNullOrEmpty(this.SponsorNameTextBox.Text.Trim()))
        {
            contentObj.SponsorName = this.SponsorNameTextBox.Text.Trim();
        }

        //artist name
        if (!string.IsNullOrEmpty(this.ArtistNameTextBox.Text.Trim()))
        {
            contentObj.ArtistName = this.ArtistNameTextBox.Text.Trim();
        }

        //format
        if (!string.IsNullOrEmpty(this.FormatTextBox.Text.Trim()))
        {
            contentObj.Format = this.FormatTextBox.Text.Trim();
        }


        //creative commons license url
        if (this.CCLicenseDropDownList.SelectedItem != null && this.CCLicenseDropDownList.SelectedValue != "None")
        {
            contentObj.CreativeCommonsLicenseURL = this.CCLicenseDropDownList.SelectedValue.Trim();

        }

        //description
        if (!string.IsNullOrEmpty(this.DescriptionTextBox.Text.Trim()))
        {
            contentObj.Description = this.DescriptionTextBox.Text.Trim();
        }

        //more information url
        if (!string.IsNullOrEmpty(this.MoreInformationURLTextBox.Text.Trim()))
        {
            contentObj.MoreInformationURL = this.MoreInformationURLTextBox.Text.Trim();

        }

        //keywords
        if (!string.IsNullOrEmpty(this.KeywordsTextBox.Text.Trim()))
        {
            contentObj.Keywords = this.KeywordsTextBox.Text.Trim();

        }


     
        if (!this.IsNew)
        {
            //update
            contentObj.LastModified = DateTime.Now;
            contentObj.LastViewed = DateTime.Now;
            UpdateContentObject(dal, contentObj);

        }
        else
        {
            //insert
            contentObj.UploadedDate = DateTime.Now;
            contentObj.LastModified = DateTime.Now;
            contentObj.Views = 0;
            contentObj.SubmitterEmail = Context.User.Identity.Name.Trim();
            SaveNewContentObject(dal, contentObj);
        }


        //TODO: Waiting for robs code to set the containsValidTextureFile
        if (this.containsValidTextureFile)
        {
            this.MultiView1.SetActiveView(this.ValidationView);

        }
        else
        {
            this.MultiView1.SetActiveView(this.MissingTextureView);

        }



    }

    protected void ValidationViewSubmitButton_Click(object sender, EventArgs e)
    {
        var factory = new vwarDAL.DataAccessFactory();
        vwarDAL.IDataRepository dal = factory.CreateDataRepositorProxy();

        ContentObject contentObj = dal.GetContentObjectById(ContentObjectID, false);


        contentObj.UnitScale = this.UnitScaleTextBox.Text.Trim();


        contentObj.UpAxis = this.UpAxisRadioButtonList.SelectedValue.Trim();


        contentObj.IntentionOfTexture = this.IntentionofTextureTextBox.Text.Trim();



        //polygons
        if (!string.IsNullOrEmpty(this.NumPolygonsTextBox.Text.Trim()))
        {

            try
            {
                contentObj.NumPolygons = Int32.Parse(this.NumPolygonsTextBox.Text.Trim());
            }
            catch
            {


            }


        }

        //textures
        if (!string.IsNullOrEmpty(this.NumTexturesTextBox.Text.Trim()))
        {

            try
            {
                contentObj.NumTextures = Int32.Parse(this.NumTexturesTextBox.Text.Trim());
            }
            catch
            {


            }


        }



        //update
        UpdateContentObject(dal, contentObj);

        //redirect
        Response.Redirect(Website.Pages.Types.Default);



    }

    private void UpdateContentObject(vwarDAL.IDataRepository dal, ContentObject co)
    {

        try
        {
            co.PID = ContentObjectID;

            dal.UpdateContentObject(co);
        }
        catch (ArgumentException ex)
        {
            errorMessage.Text = ex.Message;
        }
    }

    private void SaveNewContentObject(vwarDAL.IDataRepository dal, ContentObject co)
    {


        try
        {

            //upload main content file
            var saveMainFilePath = SaveFile(this.ContentFileUpload.FileContent, this.ContentFileUpload.FileName);
            if (IsModelUpload)
            {
                string ext = System.IO.Path.GetExtension(saveMainFilePath).ToLower();
                if (ext.Equals(".zip", StringComparison.InvariantCultureIgnoreCase))
                {
                    var path = ExtractFile(saveMainFilePath);
                    foreach (var file in Directory.GetFiles(path, "*.dae"))
                    {
						co.DisplayFile = ConvertFileToO3D(file);                        
						break;
                    }
                }

            }




            //insert model

            dal.InsertContentObject(co);
            if (IsModelUpload)
            {
                var displayFilePath = co.DisplayFile;
                co.DisplayFile = Path.GetFileName(co.DisplayFile);
                dal.UploadFile(displayFilePath, co.PID, (co.DisplayFile));
            }
            //upload images - required fields
            dal.UploadFile(saveMainFilePath, co.PID, this.ContentFileUpload.FileName);
            if (IsModelUpload)
            {
                dal.UploadFile(SaveFile(this.ThumbnailFileUpload.FileContent, this.ThumbnailFileUpload.FileName), co.PID, this.ThumbnailFileUpload.FileName);
            }
            dal.UploadFile(SaveFile(this.ThumbnailFileUpload.FileContent, this.ThumbnailFileUpload.FileName), co.PID, this.ThumbnailFileUpload.FileName);

            //upload developer logo - optional
            if (this.DeveloperLogoRadioButtonList.SelectedItem != null)
            {
                switch (this.DeveloperLogoRadioButtonList.SelectedValue.Trim())
                {
                    case "0": //use profile logo
                        DataTable dt = UserProfileDB.GetUserProfileDeveloperLogoByUserName(Context.User.Identity.Name);

                        if (dt != null && dt.Rows.Count > 0)
                        {
                            DataRow dr = dt.Rows[0];

                            if (dr["Logo"] != System.DBNull.Value && dr["LogoContentType"] != System.DBNull.Value && !string.IsNullOrEmpty(dr["LogoContentType"].ToString()))
                            {
                                var data = (byte[])dr["Logo"];
                                using (MemoryStream s = new MemoryStream())
                                {
                                    s.Write(data, 0, data.Length);
                                    s.Position = 0;

                                    //filename
                                    co.DeveloperLogoImageFileName = "developer.jpg"; ;


                                    if (!string.IsNullOrEmpty(dr["FileName"].ToString()))
                                    {
                                        co.DeveloperLogoImageFileName = dr["FileName"].ToString();
                                    }


                                    //upload the file
                                    dal.UploadFile(SaveFile(s, co.DeveloperLogoImageFileName), co.PID, co.DeveloperLogoImageFileName);
                                }
                            }
                        }



                        break;

                    case "1": //Upload logo

                        if (this.DeveloperLogoFileUpload.FileContent.Length > 0 && !string.IsNullOrEmpty(this.DeveloperLogoFileUpload.FileName))
                        {
                            co.DeveloperLogoImageFileName = this.DeveloperLogoFileUpload.FileName;
                            dal.UploadFile(SaveFile(this.DeveloperLogoFileUpload.FileContent, this.DeveloperLogoFileUpload.FileName), co.PID, this.DeveloperLogoFileUpload.FileName);
                        }


                        break;

                    case "2": //none                       

                        break;
                }

            }


            //upload sponsor logo

            if (this.SponsorLogoRadioButtonList.SelectedItem != null)
            {
                switch (this.SponsorLogoRadioButtonList.SelectedValue.Trim())
                {
                    case "0": //use profile logo
                        DataTable dt = UserProfileDB.GetUserProfileSponsorLogoByUserName(Context.User.Identity.Name);

                        if (dt != null && dt.Rows.Count > 0)
                        {
                            DataRow dr = dt.Rows[0];

                            if (dr["Logo"] != System.DBNull.Value && dr["LogoContentType"] != System.DBNull.Value && !string.IsNullOrEmpty(dr["LogoContentType"].ToString()))
                            {
                                var data = (byte[])dr["Logo"];
                                using (MemoryStream s = new MemoryStream())
                                {
                                    s.Write(data, 0, data.Length);
                                    s.Position = 0;

                                    //filename
                                    co.SponsorLogoImageFileName = "sponsor.jpg";


                                    if (!string.IsNullOrEmpty(dr["FileName"].ToString()))
                                    {
                                        co.SponsorLogoImageFileName = dr["FileName"].ToString();
                                    }



                                    dal.UploadFile(SaveFile(s, co.SponsorLogoImageFileName), co.PID, co.SponsorLogoImageFileName);
                                }
                            }


                        }


                        break;

                    case "1": //Upload logo
                        if (this.SponsorLogoFileUpload.FileContent.Length > 0 && !string.IsNullOrEmpty(this.SponsorLogoFileUpload.FileName))
                        {
                            co.SponsorLogoImageFileName = this.SponsorLogoFileUpload.FileName;
                            dal.UploadFile(SaveFile(this.SponsorLogoFileUpload.FileContent, this.SponsorLogoFileUpload.FileName), co.PID, this.SponsorLogoFileUpload.FileName);
                        }

                        break;

                    case "2": //none
                        break;
                }

            }


            //save ID to redirect to model view after confirmation
            ContentObjectID = co.PID;

            //update object
            this.UpdateContentObject(dal, co);



        }
        catch (ArgumentException ex)
        {
            errorMessage.Text = ex.Message;
        }
    }

    private string SaveFile(Stream stream, string fileName)
    {
        string savePath = Path.Combine(Path.GetTempPath(), fileName);
        if (Directory.Exists(savePath)) return savePath;
        byte[] data = new byte[stream.Length];
        stream.Read(data, 0, data.Length);
        using (FileStream fstream = new FileStream(savePath, FileMode.Create))
        {
            fstream.Write(data, 0, data.Length);
        }
        return savePath;
    }

    private string ConvertFileToO3D(string path)
    {
        var application = Path.Combine(Path.Combine(Request.PhysicalApplicationPath, "bin"), "o3dConverter.exe");
        System.Diagnostics.ProcessStartInfo processInfo = new System.Diagnostics.ProcessStartInfo(application);
        processInfo.Arguments = String.Format("\"{0}\" \"{1}\"", path, path.ToLower().Replace("dae", "o3d"));
        processInfo.WindowStyle = ProcessWindowStyle.Hidden;
        processInfo.RedirectStandardError = true;
        processInfo.CreateNoWindow = true;
        processInfo.UseShellExecute = false;
        var p = Process.Start(processInfo);
        var error = p.StandardError.ReadToEnd();
        return path.ToLower().Replace("dae", "o3d");
    }

    private void ConvertToVastpark(string path)
    {
        var application = Path.Combine(Path.Combine(Request.PhysicalApplicationPath, "bin"), "ModelPackager.exe");
        System.Diagnostics.ProcessStartInfo processInfo = new System.Diagnostics.ProcessStartInfo(application);
        processInfo.Arguments = path;
        processInfo.WindowStyle = ProcessWindowStyle.Hidden;
        processInfo.RedirectStandardError = true;
        processInfo.CreateNoWindow = true;
        processInfo.UseShellExecute = false;
        var p = Process.Start(processInfo);
        var error = p.StandardError.ReadToEnd();
    }

    private string ExtractFile(string path)
    {
        var destPath = path.Replace(".zip", string.Empty);
        using (Ionic.Zip.ZipFile zipFile = new Ionic.Zip.ZipFile(path))
        {
            zipFile.ExtractAll(destPath, Ionic.Zip.ExtractExistingFileAction.OverwriteSilently);
        }
        return destPath;
    }    

    protected void ddlAssetType_Changed(object sender, EventArgs e)
    {
        thumbNailArea.Visible = IsModelUpload;
    }

    protected void MissingTextureViewBackButton_Click(object sender, EventArgs e)
    {
        this.MultiView1.SetActiveView(this.DefaultView);
    }

    protected void MissingTextureViewNextButton_Click(object sender, EventArgs e)
    {

        this.MultiView1.SetActiveView(this.ValidationView);
    }

    protected void CancelButton_Click(object sender, EventArgs e)
    {
        Response.Redirect(Website.Pages.Types.Default);
    }

    protected void MissingTextureViewCancelButton_Click(object sender, EventArgs e)
    {
        Response.Redirect(Website.Pages.Types.Default);
    }

    protected void SkipStepButton_Click(object sender, EventArgs e)
    {
        Response.Redirect(Website.Pages.Types.Default);
    }

    protected void CCLicenseDropDownList_SelectedIndexChanged(object sender, EventArgs e)
    {
        this.BindCCLHyperLink();
    }

    private void BindCCLHyperLink()
    {

        if (this.CCLicenseDropDownList.SelectedItem != null)
        {
            this.CCLHyperLink.NavigateUrl = string.Empty;
            this.CCLHyperLink.Visible = false;

            if (this.CCLicenseDropDownList.SelectedValue.Trim().ToLower() != "none")
            {
                this.CCLHyperLink.NavigateUrl = this.CCLicenseDropDownList.SelectedValue.Trim();
                this.CCLHyperLink.Visible = true;

            }

        }




    }

    private void BindSponsorLogo(ContentObject co = null, UserProfile p = null)
    {
        string logoImageURL = "";


        //check fedora
        if (co != null && !string.IsNullOrEmpty(co.SponsorLogoImageFileName))
        {


            try
            {
                var factory = new vwarDAL.DataAccessFactory();
                vwarDAL.IDataRepository vd = factory.CreateDataRepositorProxy();
                logoImageURL = vd.GetContentUrl(co.PID, co.SponsorLogoImageFileName).Trim();
            }
            catch
            {


            }

            if (!string.IsNullOrEmpty(logoImageURL))
            {
                this.SponsorLogoImage.ImageUrl = logoImageURL.Trim();
                return;

            }

        }

        //check profile if authenticated
        if (p != null && Context.User.Identity.IsAuthenticated)
        {
            if (p.SponsorLogo != null && !string.IsNullOrEmpty(p.SponsorLogoContentType))
            {

                logoImageURL = Website.Pages.Types.FormatProfileImageHandler(p.UserID.ToString(), "Sponsor");

                if (!string.IsNullOrEmpty(logoImageURL))
                {
                    this.SponsorLogoImage.ImageUrl = logoImageURL.Trim();
                    return;

                }

            }

        }


        //Rremove use current logo from radiobuttonlist, show file upload
        if (string.IsNullOrEmpty(logoImageURL))
        {
            //clear selection
            if (this.SponsorLogoRadioButtonList.SelectedItem != null)
            {
                this.SponsorLogoRadioButtonList.ClearSelection();
            }

            //remove
            this.SponsorLogoRadioButtonList.Items.RemoveAt(0);

            //set upload new selected
            this.SponsorLogoRadioButtonList.Items.FindByValue("1").Selected = true;
            this.SponsorLogoImage.Visible = false;
            this.SponsorLogoFileUploadPanel.Visible = true;
        }

    }

    private void BindDeveloperLogo(ContentObject co = null, UserProfile p = null)
    {

        string logoImageURL = "";


        //check fedora
        if (co != null && !string.IsNullOrEmpty(co.DeveloperLogoImageFileName))
        {


            try
            {
                var factory = new vwarDAL.DataAccessFactory();
                vwarDAL.IDataRepository vd = factory.CreateDataRepositorProxy();
                logoImageURL = vd.GetContentUrl(co.PID, co.DeveloperLogoImageFileName).Trim();
            }
            catch
            {


            }

            if (!string.IsNullOrEmpty(logoImageURL))
            {
                this.DeveloperLogoImage.ImageUrl = logoImageURL.Trim();
                return;

            }

        }

        //check profile if authenticated
        if (Context.User.Identity.IsAuthenticated && p != null)
        {
            if (p.DeveloperLogo != null && !string.IsNullOrEmpty(p.DeveloperLogoContentType))
            {

                logoImageURL = Website.Pages.Types.FormatProfileImageHandler(p.UserID.ToString(), "Developer");

                if (!string.IsNullOrEmpty(logoImageURL))
                {
                    this.DeveloperLogoImage.ImageUrl = logoImageURL.Trim();
                    return;

                }

            }

        }


        //remove use current from radiobuttonlist, show file upload
        if (string.IsNullOrEmpty(logoImageURL))
        {
            //clear selection
            if (this.DeveloperLogoRadioButtonList.SelectedItem != null)
            {
                this.DeveloperLogoRadioButtonList.ClearSelection();
            }

            //remove
            this.DeveloperLogoRadioButtonList.Items.RemoveAt(0);

            //set upload new selected
            this.DeveloperLogoRadioButtonList.Items.FindByValue("1").Selected = true;
            this.DeveloperLogoImage.Visible = false;
            this.DeveloperLogoFileUploadPanel.Visible = true;
        }


    }

    protected void DeveloperLogoRadioButtonList_SelectedIndexChanged(object sender, EventArgs e)
    {
        //show/hide
        if (!string.IsNullOrEmpty(this.DeveloperLogoRadioButtonList.SelectedValue))
        {


            switch (this.DeveloperLogoRadioButtonList.SelectedValue.Trim())
            {
                case "0":
                    //use current logo
                    this.DeveloperLogoImage.Visible = true;
                    this.DeveloperLogoFileUploadPanel.Visible = false;
                    break;

                case "1":
                    //show upload control
                    this.DeveloperLogoImage.Visible = false;
                    this.DeveloperLogoFileUploadPanel.Visible = true;

                    break;

                case "2":
                    //none
                    this.DeveloperLogoImage.Visible = false;
                    this.DeveloperLogoFileUploadPanel.Visible = false;
                    break;
            }

        }



    }

    protected void SponsorLogoRadioButtonList_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(this.SponsorLogoRadioButtonList.SelectedValue))
        {


            switch (this.SponsorLogoRadioButtonList.SelectedValue.Trim())
            {
                case "0":
                    //use current logo
                    this.SponsorLogoImage.Visible = true;
                    this.SponsorLogoFileUploadPanel.Visible = false;
                    break;

                case "1":
                    //show upload control
                    this.SponsorLogoImage.Visible = false;
                    this.SponsorLogoFileUploadPanel.Visible = true;

                    break;

                case "2":
                    //none
                    this.SponsorLogoImage.Visible = false;
                    this.SponsorLogoFileUploadPanel.Visible = false;
                    break;
            }

        }
    }
}