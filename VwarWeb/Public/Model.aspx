﻿<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Model.aspx.cs" Inherits="Public_Model" Title="Model Details" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajax" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../scripts/o3djs/base.js"></script>
    <script type="text/javascript" src="../scripts/o3djs/simpleviewer.js"></script>
    <script type="text/javascript" src="../Scripts/jquery-1.3.2.min.js"></script>
    <script type="text/javascript" src="../Scripts/jquery-ui-1.7.2.custom.min.js"></script>
    <script type="text/javascript">
        var flashLoaded = false;
        var o3dLoaded = false;
        var upAxis, unitScale;
        var flashContentUrl = "";
        var o3dContentUrl = "";
        var o3dfilename;

        $(document).ready(function () {
            $('.flashTab').click(function () {
                if (o3dLoaded) {
                    uninit();
                    $('#o3d').html('');
                    o3dLoaded = false;
                }
                if (!flashLoaded) {
                    $('#flashFrame').attr("src", flashContentUrl);
                    flashLoaded = true;
                }
            });

            $('.o3dTab').click(function () {
                if (!o3dLoaded) {
                    init(o3dContentUrl, "", upAxis, unitScale);
                    o3dLoaded = true;
                }
            });

            $('.imageTab').click(function () {
                if (o3dLoaded) {
                    uninit();
                    $('#o3d').html('');
                    o3dLoaded = false;
                }
            });
        });
        
        function LoadViewerParams(url, flashLoc, o3dLoc, axis, scale) {

            upAxis = axis;
            unitScale = scale;
            var path = window.location.href;
            var index = path.lastIndexOf('/');
            o3dfilename = path.substring(path.lastIndexOf('='), path.length);
            var params = (axis != '' && scale != '') ? "&UpAxis=" + axis + "&UnitScale=" + scale : "";
            flashContentUrl = "Away3D/ViewerApplication_back.html?URL=" + path.substring(0, index + 1) + url.replace("&", "_Amp_") + flashLoc + params;
            o3dContentUrl = url + o3dLoc;
        } 
    </script>
    <style type="text/css">
        .ViewerPageContainer
        {
            background-color: white;
            border: 1px solid gray;
            height: 550px;
            position: relative;
            top: -1px;
            width: 550px;
            z-index: 0;
        }
        
        .ViewerWrapper
        {
            padding-left: 10px;
        }
        
        .ViewerItem
        {
            width: 500px;
            height: 500px;
            margin: 25px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <telerik:RadAjaxManagerProxy runat="server" ID="RadAjaxManagerProxy1">
    </telerik:RadAjaxManagerProxy>
    <div id="ModelDetails">
        <input type="hidden" runat="server" id="upAxis" />
        <input type="hidden" runat="server" id="unitScale" />
        <input type="hidden" runat="server" id="modelURL" />

         

        <table class="CenteredTable" cellpadding="4" border="0">
            <tr>
                <td height="600" width="600" class="ViewerWrapper">
               <telerik:RadTabStrip ID="ViewOptionsTab" Skin="WebBlue" runat="server" SelectedIndex="0" MultiPageID="ViewOptionsMultiPage" CssClass="front">
                <Tabs>
                <telerik:RadTab Text="Image" CssClass="imageTab"/>
                <telerik:RadTab Text="O3D Viewer" CssClass="o3dTab"/>
                <telerik:RadTab Text="Flash Viewer" CssClass="flashTab"/>
                </Tabs>
                </telerik:RadTabStrip>
                <telerik:RadMultiPage ID="ViewOptionsMultiPage" SelectedIndex="0" runat="server" CssClass="ViewerPageContainer">
                    <telerik:RadPageView ID="ImageView" runat="server" CssClass="ViewerItem">
                       <div id="scriptDisplay" runat="server" />
                        <asp:Image SkinID="Image" Height="500px" Width="500px" ID="ScreenshotImage" runat="server"
                            ToolTip='<%# Eval("Title") %>' />
                        <br />
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="O3DView" runat="server" CssClass="ViewerItem">
                     
                        <div id="o3d" style="width: 100%; height: 100%;"></div>
                        <div style="color: red;display:none;" id="loading"></div>
                        
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="FlashView" runat="server" >
                       <iframe id="flashFrame" class="ViewerItem"></iframe>
                    </telerik:RadPageView>
                </telerik:RadMultiPage>
                </td>
               <%-- <div id="tabs" style="height: 500px; width: 500px;">
                        <ul id="tabHeaders" runat="server">
                            <li><a href="#tabs-1">Image</a></li>
                            <li><a href="#tabs-3" runat="server" id="threedTab">3D</a></li>
                        </ul>
                        <div id="tabs-1" class="ui-tabs-hide" style="height: 500px; width: 500px;">
                            <div id="scriptDisplay" runat="server" />
                            <asp:Image SkinID="Image" Height="500px" Width="500px" ID="ScreenshotImage" runat="server"
                                ToolTip='<%# Eval("Title") %>' />
                            <br />
                        </div>
                        <div id="tabs-2" class="ui-tabs-hide" style="height: 500px; width: 500px;">
                            <table width="100%" style="height: 500px;">
                                <tr>
                                    <td valign="middle" align="center" height="100%">
                                        <table width="100%" style="height: 100%" border="0">
                                            <tr>
                                                <td height="100%">
                                                    <table id="container" width="500px" style="height: 500px;" border="2">
                                                        <tr>
                                                            <td height="20%">
                                                                <div id="o3d" style="width: 100%; height: 100%;">
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <div style="color: red;display:none;" id="loading">
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="tabs-3" class="ui-tabs-hide" style="height: 550px; width: 500px;">
                            <script type="text/javascript">
                                $("#displayArea").attr("src", contentUrl);                        
                            </script>
                            <iframe id="displayArea" style="height: 500px; width: 500px;"></iframe>
                        </div>
                    </div>
                   
                </td>--%> 
                <td rowspan="2">
                    &nbsp;
                </td>
                <td rowspan="2">              
                    <table border="0" cellpadding="4" cellspacing="0" width="100%">
                        <tr runat="server" id="IDRow" visible="true">
                            <td>
                                
                            <asp:HyperLink ID="editLink" Visible="false" runat="server" Text="Edit" ImageUrl="~/Images/Edit_BTN.png"></asp:HyperLink>
                                
                                <asp:Label ID="IDLabel" runat="server" Visible="false"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                 
                                <div class="ListTitle">
                                    <div>
                                        3D Asset</div>
                                </div>
                                <br />
                                <table border="0" style="margin-left: 5px;">
                                    <tr>
                                        <td>
                                            <asp:Label ID="TitleLabel" runat="server" CssClass="ModelTitle"></asp:Label>
                                            <asp:HyperLink ID="SubmitterEmailHyperLink" runat="server" CssClass="Hyperlink" Visible="false">[SubmitterEmailHyperLink]</asp:HyperLink>
                                                
                                        </td>
                                        <td style="text-align: center;">
                                            <asp:HyperLink ID="CCLHyperLink" runat="server" Target="_blank" CssClass="Hyperlink" />
                                        </td>
                                    </tr>
                                    <tr runat="server" id="DescriptionRow">
                                        <td>
                                            <asp:Label ID="DescriptionLabel" runat="server" />
                                        </td>
                                        <td style="text-align: center;">
                                            <asp:LinkButton ID="ReportViolationButton" CssClass="Hyperlink" runat="server" Text="Report a Violation"
                                                OnClick="ReportViolationButton_Click" />
                                        </td>
                                    </tr>
                                    <tr runat="server" id="KeywordsRow">
                                        <td>
                                            <br />
                                            <span runat="server" id="keywordLabel">Keywords:</span> <span id="keywords" runat="server">
                                            </span>
                                        </td>
                                        <td>
                                            <table border="0" class="CenteredTable">
                                                <tr>
                                                    <td>
                                                        <ajax:Rating ID="ir" runat="server" CurrentRating='<%# Website.Common.CalculateAverageRating(Eval("Id")) %>'
                                                            MaxRating="5" StarCssClass="ratingStar" WaitingStarCssClass="savedRatingStar"
                                                            FilledStarCssClass="filledRatingStar" EmptyStarCssClass="emptyRatingStar" ReadOnly="true">
                                                        </ajax:Rating>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <br />
                                           <div>
                                            Available File Formats
                                                <telerik:RadComboBox ID="ModelTypeDropDownList" runat="server" CausesValidation="False"
                                                    EnableEmbeddedSkins="false">
                                                    <Items>
                                                        <telerik:RadComboBoxItem runat="server" Text="No Conversion" Value="" />
                                                        <telerik:RadComboBoxItem runat="server" Text="Collada" Value=".dae" />
                                                        <telerik:RadComboBoxItem runat="server" Text="OBJ" Value=".obj" />
                                                        <telerik:RadComboBoxItem runat="server" Text="3DS" Value=".3DS" />
                                                        <telerik:RadComboBoxItem runat="server" Text="O3D" Value=".O3Dtgz" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </div>
                                        </td>
                                        <td style="vertical-align: bottom; text-align: center;">
                                            <asp:ImageButton ID="DownloadButton" runat="server" Text="Download" ToolTip="Download"
                                                CommandName="DownloadZip" OnClick="DownloadButton_Click" ImageUrl="~/Images/Download_BTN.png" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="ListTitle">
                                    <div>
                                        Developer Information</div>
                                </div>
                                <table border="0" style="margin-left: 5px;">
                                    <tr runat="server" id="DeveloperLogoRow">
                                        <td>
                                            <%--<asp:Image ID="DeveloperLogoImage" runat="server" ImageUrl= />--%>
                                            <telerik:RadBinaryImage ID="DeveloperLogoImage" runat="server"  />
                            
                                        </td>
                                    </tr>
                                    <tr runat="server" id="SubmitterEmailRow">
                                        <td>
                                            <asp:Label ID="UploadedDateLabel" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="DeveloperRow">
                                        <td>
                                            Developer Name:
                                            <asp:HyperLink ID="DeveloperNameHyperLink" runat="server" NavigateUrl="#" CssClass="Hyperlink">[DeveloperNameHyperLink]</asp:HyperLink>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="MoreDetailsRow">
                                        <td>
                                            <br />
                                            <asp:HyperLink ID="MoreDetailsHyperLink" runat="server" Target="_blank" CssClass="Hyperlink" />&nbsp;<asp:Image ID="ExternalLinkIcon" runat="server" ImageUrl="~/Images/externalLink.gif" Width="15px" Height="15px" ImageAlign="Bottom" />
                                        </td>
                                    </tr>
                                </table>
                            </td>   
                        </tr>
                        <tr>
                            <td>
                                <div class="ListTitle">
                                    <div>
                                        Sponsor Information</div>
                                </div>
                                <table border="0" style="margin-left: 5px;">
                                    <tr runat="server" id="SponsorLogoRow">
                                        <td>
                                             <telerik:RadBinaryImage ID="SponsorLogoImage" runat="server"  />
                          
                                            <%--<asp:Image ID="SponsorLogoImage" runat="server" />--%>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="SponsorNameRow">
                                        <td>
                                            Sponsor Name:
                                            <asp:Label ID="SponsorNameLabel" runat="server" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="ListTitle">
                                    <div>
                                        Asset Details</div>
                                </div>
                                <table border="0" style="margin-left: 5px;">
                                    <tr>
                                        <td>
                                            <asp:Label ID="FormatLabel" runat="server" />
                                        </td>
                                    </tr>
                                    <tr runat="server" id="NumPolygonsRow">
                                        <td>
                                            <br />
                                            Number of Polygons:
                                            <asp:Label ID="NumPolygonsLabel" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="NumTexturesRow">
                                        <td>
                                            Number of Textures:
                                            <asp:Label ID="NumTexturesLabel" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="DownloadsRow">
                                        <td>
                                            <br />
                                            Downloads:
                                            <asp:Label ID="DownloadsLabel" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="ViewsRow">
                                        <td>
                                            Views:
                                            <asp:Label ID="ViewsLabel" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:UpdatePanel ID="updatePanel" runat="server" EnableViewState="true" ChildrenAsTriggers="true">
                        <ContentTemplate>
                           
                            <div class="ListTitle" style="width:550px; margin-left:6px;">
                                <div>
                                    Comments and Reviews</div>
                            </div>
                            <br />
                            <asp:Label ID="NotRatedLabel" runat="server" Font-Bold="true" Text="Not yet rated.  Be the first to rate!<br /><br />" Visible="false"></asp:Label>
                            <div style="margin-left:5px;">
                            <ajax:Rating ID="rating" runat="server" CurrentRating="3" MaxRating="5" StarCssClass="ratingStar"
                                OnChanged="Rating_Set" WaitingStarCssClass="savedRatingStar" FilledStarCssClass="filledRatingStar"
                                EmptyStarCssClass="emptyRatingStar">
                            </ajax:Rating>
                            <br />
                            <asp:TextBox ID="ratingText" runat="server" TextMode="MultiLine" Columns="50" SkinID="TextBox"
                                Rows="4"></asp:TextBox>
                            <br />
                            <asp:ImageButton ID="submitRating" Text="Add Rating" runat="server" OnClick="Rating_Click"
                                ImageUrl="~/Images/Add_Rating_BTN.png" />
                            <br />
                            <br />
                            <asp:GridView ID="CommentsGridView" runat="server" AutoGenerateColumns="false" BorderStyle="None"
                                GridLines="None" ShowHeader="false">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                           <ajax:Rating ID="ir" runat="server" CurrentRating='<%# Eval("Rating") %>'
                                                                MaxRating="5" StarCssClass="ratingStar" WaitingStarCssClass="savedRatingStar"
                                                                FilledStarCssClass="filledRatingStar" EmptyStarCssClass="emptyRatingStar" ReadOnly="false">
                                                            </ajax:Rating>
                                            <br />
                                            <asp:Label ID="Label2" Text='<%# Eval("Text") %>' runat="server"></asp:Label>
                                            <br />
                                            Submitted By:
                                            <asp:Label Text='<%#Website.Common.GetFullUserName( Eval("SubmittedBy")) %>' runat="server"></asp:Label>
                                            On
                                            <asp:Label ID="Label1" Text='<%# Eval("SubmittedDate","{0:d}") %>' runat="server"></asp:Label>
                                            <hr />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>

                            </div>



                        </ContentTemplate>
                    </asp:UpdatePanel>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
