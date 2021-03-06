<%--
Copyright 2011 U.S. Department of Defense

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--%>



<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true"
    CodeFile="Contact.aspx.cs" Inherits="Public_Contact" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
    	function prevalidate() {
    		if(Page_IsValid) {
    			$("#LoadingModal").show();
    		}
    	}
    </script>
    <style type="text/css">
        #MainContent
        {
            text-align: center;
            margin-left: auto;
            margin-right: auto;
            width: 525px;
        }
        #LoadingModal
        {
            background-color: #FFFFFF;
            left: 0;
            opacity: 0.7;
            position: relative;
            text-align: center;
            top: -466px;
            width: 525px;
            display: none;
            height: 390px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="MainContent">
    <asp:UpdatePanel runat="server" HorizontalAlign="NotSet" Width="525px" LoadingPanelID="SubmitLoader"
        ID="FormFieldsPanel">
        <ContentTemplate>
        <div id="FormFields">
            <div class="ListTitle">
                Contact Us</div>
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" style="width: 525px">
                        <asp:Panel ID="DefaultPanel" runat="server" Visible="true">
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    First Name<span class="Red">*</span><asp:RequiredFieldValidator Font-Bold="True"
                                                        ID="RequiredFieldValidator2" runat="server" ControlToValidate="FirstNameTextBox"
                                                        ErrorMessage="'First Name' is required" ForeColor="White" Text="*"></asp:RequiredFieldValidator><br />
                                                    <asp:TextBox ID="FirstNameTextBox" runat="server" Width="200px"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                        <table>
                                            <tr>
                                                <td>
                                                    Last Name<span class="Red">*</span><asp:RequiredFieldValidator Font-Bold="True" ID="RequiredFieldValidator3"
                                                        runat="server" ControlToValidate="LastNameTextBox" ErrorMessage="'Last Name' is required"
                                                        ForeColor="White" Text="*"></asp:RequiredFieldValidator><br />
                                                    <asp:TextBox ID="LastNameTextBox" runat="server" Width="200px"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        E-Mail Address<span class="Red">*</span><asp:RequiredFieldValidator Font-Bold="True"
                                            ID="RequiredFieldValidator4" runat="server" ControlToValidate="EmailTextBox"
                                            ErrorMessage="'Email Address' is required" ForeColor="White" Text="*"></asp:RequiredFieldValidator><br />
                                        <asp:TextBox ID="EmailTextBox" runat="server" Width="200px"></asp:TextBox>
                                    </td>
                                    <td>
                                        Phone Number<span class="Red">*</span><asp:RequiredFieldValidator Font-Bold="True"
                                            ID="RequiredFieldValidator5" runat="server" ControlToValidate="PhoneNumberTextBox"
                                            ErrorMessage="'Phone Number' is required" ForeColor="White" Text="*"></asp:RequiredFieldValidator><br />
                                        <asp:TextBox ID="PhoneNumberTextBox" Width="200px" runat="server"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        My question relates to<span class="Red">*</span><asp:RequiredFieldValidator Font-Bold="True"
                                            ID="RequiredFieldValidator7" runat="server" ControlToValidate="MyQuestionRelatesToDropDownList"
                                            ErrorMessage="'My question relates to' is required" ForeColor="White" Text="*"></asp:RequiredFieldValidator><br />
                                        <asp:DropDownList ID="MyQuestionRelatesToDropDownList" runat="server">
                                            <asp:ListItem Selected="True"></asp:ListItem>
                                            <asp:ListItem>General</asp:ListItem>
                                            <asp:ListItem>Web Site</asp:ListItem>
                                            <asp:ListItem>Support</asp:ListItem>
                                            <asp:ListItem>Other</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        Questions/Comments<span class="Red">*</span><asp:RequiredFieldValidator Font-Bold="True"
                                            ID="RequiredFieldValidator8" runat="server" ControlToValidate="QuestionsTextBox"
                                            ErrorMessage="'Questions/Comments' are required" ForeColor="White" Text="*"></asp:RequiredFieldValidator><br />
                                        <asp:TextBox ID="QuestionsTextBox" Width="400px" runat="server" TextMode="MultiLine"
                                            Rows="5"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:Label ID="ErrorMessageLabel" runat="server" CssClass="Red"></asp:Label>
                                        <asp:ValidationSummary ID="ValidationSummary1" runat="server" ShowMessageBox="True"
                                            ShowSummary="False" />
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                        
                        <br />
                    </td>
                </tr>
                <tr>
                    <td colspan="2" align="left">
                        <br />
                        <asp:Button ID="SubmitButton" runat="server" Text="Submit" OnClick="SubmitButton_Click" OnClientClick="prevalidate()"/>&nbsp;
                        <asp:Button ID="Button1" runat="server" OnClick="CancelButton_Click" Text="Cancel"
                             CausesValidation="false" />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                    </td>
                </tr>
            </table>
        </div>
        <div id="Status" style="display: none; text-align: center">
            <asp:Label ID="StatusLabel" runat="server" CssClass="Bold"></asp:Label>
            <br />
            <br />
        </div>
        <div id="LoadingModal">
            <img src="../styles/images/Icons/loadingThumbnail.gif" 
                 style="position:relative; top: 25%;" alt="Loading Thumbnail" />
        </div> 
    </ContentTemplate>
    </asp:UpdatePanel>
    </div>
</asp:Content>
