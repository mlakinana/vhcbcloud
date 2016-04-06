﻿using DataAccessLayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using VHCBCommon.DataAccessLayer;

namespace vhcbcloud
{
    public partial class ProjectMaintenance : System.Web.UI.Page
    {
        string Pagename = "ProjectMaintenance";

        protected void Page_Load(object sender, EventArgs e)
        {
            dvMessage.Visible = false;
            lblErrorMsg.Text = "";

            if (!IsPostBack)
            {
                BindControls();
                DisplayControlsbasedOnSelection();
            }
        }

        #region Bind Controls
        private void BindControls()
        {
            BindLookUP(ddlAppStatus, 83);
            BindLookUP(ddlProgram, 34);
            BindLookUP(ddlProjectType, 119);
            BindBoardDate();
            BindManagers();
            BindPrimaryApplicants();
            BindProjects();
            BindApplicants();
        }

        protected void BindProjects()
        {
            try
            {
                ddlProject.Items.Clear();
                ddlProject.DataSource = ProjectCheckRequestData.GetData("getprojectslist"); ;
                ddlProject.DataValueField = "projectid";
                ddlProject.DataTextField = "Proj_num";
                ddlProject.DataBind();
                ddlProject.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = ex.Message;
            }
        }
        private void BindBoardDate()
        {
            try
            {
                ddlBoardDate.Items.Clear();
                ddlBoardDate.DataSource = LookupValuesData.GetBoardDates();
                ddlBoardDate.DataValueField = "TypeID";
                ddlBoardDate.DataTextField = "MeetingType";
                ddlBoardDate.DataBind();
                ddlBoardDate.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindApplicants", "", ex.Message);
            }
        }

        private void BindPrimaryApplicants()
        {
            try
            {
                ddlPrimaryApplicant.Items.Clear();
                ddlPrimaryApplicant.DataSource = ApplicantData.GetSortedApplicants();
                ddlPrimaryApplicant.DataValueField = "appnameid";
                ddlPrimaryApplicant.DataTextField = "Applicantname";
                ddlPrimaryApplicant.DataBind();
                ddlPrimaryApplicant.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindPrimaryApplicants", "", ex.Message);
            }
        }

        protected void BindManagers()
        {
            try
            {
                ddlManager.Items.Clear();
                ddlManager.DataSource = LookupValuesData.GetManagers();
                ddlManager.DataValueField = "UserId";
                ddlManager.DataTextField = "Name";
                ddlManager.DataBind();
                ddlManager.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindManagers", "", ex.Message);
            }
        }

        private void BindLookUP(DropDownList ddList, int LookupType)
        {
            try
            {
                ddList.Items.Clear();
                ddList.DataSource = LookupValuesData.Getlookupvalues(LookupType);
                ddList.DataValueField = "typeid";
                ddList.DataTextField = "description";
                ddList.DataBind();
                ddList.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindLookUP", "Control ID:" + ddList.ID, ex.Message);
            }
        }

        protected void BindApplicants()
        {
            try
            {
                ddlApplicantName.Items.Clear();
                ddlApplicantName.DataSource = ApplicantData.GetSortedApplicants();
                ddlApplicantName.DataValueField = "appnameid";
                ddlApplicantName.DataTextField = "Applicantname";
                ddlApplicantName.DataBind();
                ddlApplicantName.Items.Insert(0, new ListItem("Select", "NA"));
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindApplicants", "", ex.Message);
            }
        }
        #endregion

        private void LogError(string pagename, string method, string message, string error)
        {
            dvMessage.Visible = true;
            if (message == "")
            {
                lblErrorMsg.Text = Pagename + ": " + method + ": Error Message: " + error;
            }
            else
                lblErrorMsg.Text = Pagename + ": " + method + ": Message :" + message + ": Error Message: " + error;
        }

        private void LogMessage(string message)
        {
            dvMessage.Visible = true;
            lblErrorMsg.Text = message;
        }

        private void ClearForm()
        {
            txtProjNum.Text = "";
            ddlProjectType.SelectedIndex = -1;
            ddlProgram.SelectedIndex = -1;
            txtApplicationReceived.Text = "";
            ddlAppStatus.SelectedIndex = -1;
            ddlManager.SelectedIndex = -1;
            ddlBoardDate.SelectedIndex = -1;
            txtClosingDate.Text = "";
            txtGrantExpirationDate.Text = "";
            cbVerified.Checked = false;
            ddlPrimaryApplicant.SelectedIndex = -1;
            txtProjectName.Text = "";
        }

        protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                ClearForm();

                hfProjectId.Value = "";
                if (ddlProject.SelectedIndex != 0)
                {
                    dvUpdate.Visible = true;
                    //string[] tokens = ddlProject.SelectedValue.ToString().Split('|');
                    //txtProjectName.Text = tokens[1];
                    hfProjectId.Value = ddlProject.SelectedValue.ToString();

                    BindProjectInfoForm(DataUtils.GetInt(hfProjectId.Value));

                    //ProjectNames
                    dvNewProjectName.Visible = true;
                    dvProjectName.Visible = false;
                    dvProjectNamesGrid.Visible = true;
                    BindProjectNamesGrid();

                    //Address
                    dvNewAddress.Visible = true;
                    dvAddress.Visible = false;
                    dvAddressGrid.Visible = true;
                    BindAddressGrid();

                    //Entity
                    dvNewEntity.Visible = true;
                    dvEntity.Visible = false;
                    dvEntityGrid.Visible = true;
                    BindProjectEntityGrid();
                }
                else
                {
                    dvUpdate.Visible = false;

                    //ProjectNames
                    dvNewProjectName.Visible = false;
                    dvProjectName.Visible = false;
                    dvProjectNamesGrid.Visible = false;

                    //Address
                    dvNewAddress.Visible = false;
                    dvAddress.Visible = false;
                    dvAddressGrid.Visible = false;

                    //Entity
                    dvNewEntity.Visible = false;
                    dvEntity.Visible = false;
                    dvEntityGrid.Visible = false;
                }

            }
            catch (Exception ex)
            {
                LogError(Pagename, "ddlProject_SelectedIndexChanged", "", ex.Message);
            }
        }

        private void BindProjectNamesGrid()
        {
            try
            {
                DataTable dtProjectNames = ProjectMaintenanceData.GetProjectNames(DataUtils.GetInt(hfProjectId.Value));

                if (dtProjectNames.Rows.Count > 1)
                {
                    dvProjectNamesGrid.Visible = true;
                    gvProjectNames.DataSource = dtProjectNames;
                    gvProjectNames.DataBind();
                }
                else
                    dvProjectNamesGrid.Visible = false;
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindProjectNamesGrid", "", ex.Message);
            }
        }

        private void BindAddressGrid()
        {
            try
            {
                DataTable dtAddress = ProjectMaintenanceData.GetProjectAddressList(DataUtils.GetInt(hfProjectId.Value));

                if (dtAddress.Rows.Count > 0)
                {
                    dvAddressGrid.Visible = true;
                    gvAddress.DataSource = dtAddress;
                    gvAddress.DataBind();
                }
                else
                    dvAddressGrid.Visible = false;
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindProjectNamesGrid", "", ex.Message);
            }
        }

        private void BindProjectInfoForm(int ProjectId)
        {
            DataRow drProjectDetails = ProjectMaintenanceData.GetprojectDetails(ProjectId);
            PopulateDropDown(ddlProgram, drProjectDetails["LkProgram"].ToString());
            PopulateDropDown(ddlAppStatus, drProjectDetails["LkAppStatus"].ToString());
            PopulateDropDown(ddlManager, drProjectDetails["Manager"].ToString());
            PopulateDropDown(ddlBoardDate, drProjectDetails["LkBoardDate"].ToString());
            PopulateDropDown(ddlPrimaryApplicant, drProjectDetails["AppNameId"].ToString());
            PopulateDropDown(ddlProjectType, drProjectDetails["LkProjectType"].ToString());

            txtProjectName.Text = drProjectDetails["projectName"].ToString();
            txtApplicationReceived.Text = drProjectDetails["AppRec"].ToString() == "" ? "" : Convert.ToDateTime(drProjectDetails["AppRec"].ToString()).ToShortDateString();
            txtClosingDate.Text = drProjectDetails["ClosingDate"].ToString() == "" ? "" : Convert.ToDateTime(drProjectDetails["ClosingDate"].ToString()).ToShortDateString();
            txtGrantExpirationDate.Text = drProjectDetails["ExpireDate"].ToString() == "" ? "" : Convert.ToDateTime(drProjectDetails["ExpireDate"].ToString()).ToShortDateString();
            cbVerified.Checked = DataUtils.GetBool(drProjectDetails["verified"].ToString());
        }

        private void PopulateDropDown(DropDownList ddl, string DBSelectedvalue)
        {
            foreach (ListItem item in ddl.Items)
            {
                if (DBSelectedvalue == item.Value.ToString())
                {
                    ddl.ClearSelection();
                    item.Selected = true;
                }
            }
        }

        protected void rdBtnSelection_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlProject.SelectedIndex = -1;
            DisplayControlsbasedOnSelection();

            dvUpdate.Visible = false;

            //ProjectNames
            dvNewProjectName.Visible = false;
            dvProjectName.Visible = false;
            dvProjectNamesGrid.Visible = false;

            //Address
            dvNewAddress.Visible = false;
            dvAddress.Visible = false;
            dvAddressGrid.Visible = false;

            //Entity
            dvNewEntity.Visible = false;
            dvEntity.Visible = false;
            dvEntityGrid.Visible = false;
        }

        private void DisplayControlsbasedOnSelection()
        {
            ClearForm();
            if (rdBtnSelection.SelectedValue.ToLower().Trim() == "new")
            {
                txtProjNum.Visible = true;
                ddlProject.Visible = false;
                btnProjectUpdate.Visible = false;
                btnProjectSubmit.Visible = true;
            }
            else
            {
                txtProjNum.Visible = false;
                ddlProject.Visible = true;
                btnProjectUpdate.Visible = true;
                btnProjectSubmit.Visible = false;

                //ProjectNames
                dvNewProjectName.Visible = false;
                dvProjectName.Visible = false;
                dvProjectNamesGrid.Visible = false;

                //Address
                dvNewAddress.Visible = false;
                dvAddress.Visible = false;
                dvAddressGrid.Visible = false;

                //Entity
                dvNewEntity.Visible = false;
                dvEntity.Visible = false;
                dvEntityGrid.Visible = false;
            }
        }

        protected void btnProjectSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                string isDuplicate = ProjectMaintenanceData.AddProject(txtProjNum.Text, DataUtils.GetInt(ddlProjectType.SelectedValue.ToString()), DataUtils.GetInt(ddlProgram.SelectedValue.ToString()),
                     DateTime.Parse(txtApplicationReceived.Text), DataUtils.GetInt(ddlAppStatus.SelectedValue.ToString()), DataUtils.GetInt(ddlManager.SelectedValue.ToString()),
                    DataUtils.GetInt(ddlBoardDate.SelectedValue.ToString()), DateTime.Parse(txtClosingDate.Text), DateTime.Parse(txtGrantExpirationDate.Text), cbVerified.Checked,
                    DataUtils.GetInt(ddlPrimaryApplicant.SelectedValue.ToString()), txtProjectName.Text);

                if (isDuplicate.ToLower() == "true")
                    LogMessage("Project already exist");
                else
                    LogMessage("Project added successfully");

                ClearForm();
            }
            catch (Exception ex)
            {
                LogError(Pagename, "btnProjectSubmit_Click", "", ex.Message);
            }
        }

        protected void btnProjectUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                //string[] tokens = ddlProject.SelectedValue.ToString().Split('|');
                //txtProjectName.Text = tokens[1];

                ProjectMaintenanceData.UpdateProject((DataUtils.GetInt(hfProjectId.Value)), DataUtils.GetInt(ddlProjectType.SelectedValue.ToString()), DataUtils.GetInt(ddlProgram.SelectedValue.ToString()),
                     txtApplicationReceived.Text, DataUtils.GetInt(ddlAppStatus.SelectedValue.ToString()), DataUtils.GetInt(ddlManager.SelectedValue.ToString()),
                    DataUtils.GetInt(ddlBoardDate.SelectedValue.ToString()), txtClosingDate.Text, txtGrantExpirationDate.Text, cbVerified.Checked,
                    DataUtils.GetInt(ddlPrimaryApplicant.SelectedValue.ToString()), txtProjectName.Text);

                LogMessage("Project updated successfully");

                ClearForm();
                ddlProject.SelectedIndex = -1;

                dvUpdate.Visible = false;

                //ProjectNames
                dvNewProjectName.Visible = false;
                dvProjectName.Visible = false;
                dvProjectNamesGrid.Visible = false;

                //Address
                dvNewAddress.Visible = false;
                dvAddress.Visible = false;
                dvAddressGrid.Visible = false;

                //Entity
                dvNewEntity.Visible = false;
                dvEntity.Visible = false;
                dvEntityGrid.Visible = false;
            }
            catch (Exception ex)
            {
                LogError(Pagename, "btnProjectUpdate_Click", "", ex.Message);
            }
        }

        protected void btnAddProjectName_Click(object sender, EventArgs e)
        {
            try
            {
                ProjectMaintenanceData.AddProjectName(DataUtils.GetInt(hfProjectId.Value), txtProject_Name.Text, cbDefName.Checked);

                ClearProjectNameForm();
                dvProjectName.Visible = false;
                dvProjectNamesGrid.Visible = true;
                cbAddProjectName.Checked = false;
                BindProjectNamesGrid();
                BindProjectInfoForm(DataUtils.GetInt(hfProjectId.Value));
                LogMessage("Project name added successfully");
            }
            catch (Exception ex)
            {
                LogError(Pagename, "btnAddProjectName_Click", "", ex.Message);
            }
        }

        private void ClearProjectNameForm()
        {
            txtProject_Name.Text = "";
            cbDefName.Checked = true;
        }

        protected void cbProjectName_CheckedChanged(object sender, EventArgs e)
        {
            if (cbAddProjectName.Checked)
                dvProjectName.Visible = true;
            else
                dvProjectName.Visible = false;
        }

        #region gvProjectNames
        protected void gvProjectNames_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvProjectNames.EditIndex = e.NewEditIndex;
            BindProjectNamesGrid();
        }

        protected void gvProjectNames_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int rowIndex = e.RowIndex;
            string projectName = ((TextBox)gvProjectNames.Rows[rowIndex].FindControl("txtDescription")).Text;
            int typeid = Convert.ToInt32(((Label)gvProjectNames.Rows[rowIndex].FindControl("lblTypeId")).Text);
            bool isDefName = Convert.ToBoolean(((CheckBox)gvProjectNames.Rows[rowIndex].FindControl("chkDefName")).Checked);

            ProjectMaintenanceData.UpdateProjectname(DataUtils.GetInt(hfProjectId.Value), typeid, projectName, isDefName);
            gvProjectNames.EditIndex = -1;

            BindProjectNamesGrid();
            BindProjectInfoForm(DataUtils.GetInt(hfProjectId.Value));
            LogMessage("Project Name updated successfully");
        }

        protected void gvProjectNames_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvProjectNames.EditIndex = -1;
            BindProjectNamesGrid();
        }

        protected void gvProjectNames_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {
                if ((e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
                {
                    CommonHelper.GridViewSetFocus(e.Row);
                    //Checking whether the Row is Data Row
                    if (e.Row.RowType == DataControlRowType.DataRow)
                    {
                        CheckBox chkDefName = e.Row.FindControl("chkDefName") as CheckBox;

                        if (chkDefName.Checked)
                            chkDefName.Enabled = false;
                        else
                            chkDefName.Enabled = true;
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(Pagename, "gvAddress_RowDataBound", "", ex.Message);
            }
        }

        #endregion

        protected void cbAddAddress_CheckedChanged(object sender, EventArgs e)
        {
            if (cbAddAddress.Checked)
                dvAddress.Visible = true;
            else
                dvAddress.Visible = false;
        }

        protected void gvAddress_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvAddress.EditIndex = -1;
            BindAddressGrid();
        }

        protected void gvAddress_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvAddress.EditIndex = e.NewEditIndex;
            BindAddressGrid();
        }

        protected void gvAddress_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int rowIndex = e.RowIndex;
            string projectName = ((TextBox)gvProjectNames.Rows[rowIndex].FindControl("txtDescription")).Text;
            int typeid = Convert.ToInt32(((Label)gvProjectNames.Rows[rowIndex].FindControl("lblTypeId")).Text);
            bool isDefName = Convert.ToBoolean(((CheckBox)gvProjectNames.Rows[rowIndex].FindControl("chkDefName")).Checked);

            gvAddress.EditIndex = -1;
            BindAddressGrid();
            LogMessage("Address updated successfully");
        }

        protected void btnAddAddress_Click(object sender, EventArgs e)
        {
            int ProjectId = DataUtils.GetInt(hfProjectId.Value);

            if (btnAddAddress.Text.ToLower() == "update")
            {
                int addressId = Convert.ToInt32(hfAddressId.Value);

                ProjectMaintenanceData.UpdateProjectAddress(ProjectId, addressId, txtStreetNo.Text, txtAddress1.Text, txtAddress2.Text, txtTown.Text, null,
                    txtState.Text, txtZip.Text, txtCounty.Text, 0, 0, cbActive.Checked, cbDefaultAddress.Checked);

                hfAddressId.Value = "";
                btnAddAddress.Text = "Add";
                LogMessage("Address updated successfully");
            }
            else //add
            {
                ProjectMaintenanceData.AddProjectAddress(ProjectId, txtStreetNo.Text, txtAddress1.Text, txtAddress2.Text, txtTown.Text, null,
                    txtState.Text, txtZip.Text, txtCounty.Text, 0, 0, cbActive.Checked, cbDefaultAddress.Checked);

                btnAddAddress.Text = "Add";
                LogMessage("New Address added successfully");
            }

            gvAddress.EditIndex = -1;
            BindAddressGrid();
            ClearAddressForm();
            dvAddress.Visible = false;
            dvAddressGrid.Visible = true;
            cbAddAddress.Checked = false;
        }

        private void ClearAddressForm()
        {
            txtStreetNo.Text = "";
            txtAddress1.Text = "";
            txtAddress2.Text = "";
            txtTown.Text = "";
            txtState.Text = "";
            txtZip.Text = "";
            txtCounty.Text = "";
            cbActive.Checked = false;
            cbDefaultAddress.Checked = false;
        }

        protected void gvAddress_RowCancelingEdit1(object sender, GridViewCancelEditEventArgs e)
        {
            //gvAddress.EditIndex = -1;
            //BindAddressGrid();

            ClearAddressForm();
            btnAddAddress.Text = "Add";
            dvAddress.Visible = false;
            gvAddress.EditIndex = -1;
            BindAddressGrid();
        }

        protected void gvAddress_RowEditing1(object sender, GridViewEditEventArgs e)
        {
            gvAddress.EditIndex = e.NewEditIndex;
            BindAddressGrid();
        }

        protected void gvAddress_RowUpdating1(object sender, GridViewUpdateEventArgs e)
        {

        }

        protected void gvAddress_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {
                if ((e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
                {
                    CommonHelper.GridViewSetFocus(e.Row);
                    btnAddAddress.Text = "Update";
                    dvAddress.Visible = true;

                    //Checking whether the Row is Data Row
                    if (e.Row.RowType == DataControlRowType.DataRow)
                    {
                        Label lblAddressId = e.Row.FindControl("lblAddressId") as Label;
                        DataRow dr = ProjectMaintenanceData.GetProjectAddressDetailsById(DataUtils.GetInt(hfProjectId.Value), Convert.ToInt32(lblAddressId.Text));

                        hfAddressId.Value = lblAddressId.Text;

                        txtStreetNo.Text = dr["Street#"].ToString();
                        txtAddress1.Text = dr["Address1"].ToString();
                        txtAddress2.Text = dr["Address2"].ToString();
                        txtTown.Text = dr["Town"].ToString(); ;
                        txtState.Text = dr["State"].ToString();
                        txtZip.Text = dr["Zip"].ToString();
                        txtCounty.Text = dr["County"].ToString();
                        txtLattitude.Text = dr["latitude"].ToString();
                        txtLongitude.Text = dr["longitude"].ToString();
                        cbActive.Checked = DataUtils.GetBool(dr["RowIsActive"].ToString());
                        cbDefaultAddress.Checked = DataUtils.GetBool(dr["PrimaryAdd"].ToString());
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(Pagename, "gvAddress_RowDataBound", "", ex.Message);
            }
        }

        protected void btnAddEntity_Click(object sender, EventArgs e)
        {
            ProjectMaintenanceData.AddProjectApplicant(DataUtils.GetInt(hfProjectId.Value), DataUtils.GetInt(ddlApplicantName.SelectedValue.ToString()));

            ddlApplicantName.SelectedIndex = -1;

            LogMessage("Entity Attached Successfully");

            gvEntity.EditIndex = -1;
            BindProjectEntityGrid();
            dvEntity.Visible = false;
            dvEntityGrid.Visible = true;
            cbAttachNewEntity.Checked = false;
        }

        private void BindProjectEntityGrid()
        {
            try
            {
                DataTable dtProjectEntity = ProjectMaintenanceData.GetProjectApplicantList(DataUtils.GetInt(hfProjectId.Value));

                if (dtProjectEntity.Rows.Count > 0)
                {
                    gvEntity.Visible = true;
                    gvEntity.DataSource = dtProjectEntity;
                    gvEntity.DataBind();
                }
                else
                    gvEntity.Visible = false;
            }
            catch (Exception ex)
            {
                LogError(Pagename, "BindProjectNamesGrid", "", ex.Message);
            }
        }

        protected void cbAttachNewEntity_CheckedChanged(object sender, EventArgs e)
        {
            if (cbAttachNewEntity.Checked)
                dvEntity.Visible = true;
            else
                dvEntity.Visible = false;
        }
    }
}