﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace VHCBCommon.DataAccessLayer.Viability
{
    public class EnterpriseEvaluationsData
    {
        public static ViabilityMaintResult AddEnterpriseEvalMilestones(int ProjectID, int Milestone, DateTime MSDate, string Comment, 
            string LeadPlanAdvisorExp, bool PlanProcess, decimal LoanReq, decimal LoanRec, decimal LoanPend, decimal GrantReq, decimal GrantRec,
            decimal GrantPend, decimal OtherReq, decimal OtherRec, decimal OtherPend, decimal SharedOutcome, decimal QuoteUse, decimal QuoteName)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConnection"].ConnectionString))
                {
                    connection.Open();

                    using (SqlCommand command = new SqlCommand())
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "AddEnterpriseEvalMilestones";

                        command.Parameters.Add(new SqlParameter("ProjectId", ProjectID));
                        command.Parameters.Add(new SqlParameter("Milestone", Milestone));
                        command.Parameters.Add(new SqlParameter("MSDate", MSDate));
                        command.Parameters.Add(new SqlParameter("Comment", Comment));
                        command.Parameters.Add(new SqlParameter("LeadPlanAdvisorExp", LeadPlanAdvisorExp));
                        command.Parameters.Add(new SqlParameter("PlanProcess", PlanProcess));
                        command.Parameters.Add(new SqlParameter("LoanReq", LoanReq));
                        command.Parameters.Add(new SqlParameter("LoanRec", LoanRec));
                        command.Parameters.Add(new SqlParameter("LoanPend", LoanPend));
                        command.Parameters.Add(new SqlParameter("GrantReq", GrantReq));
                        command.Parameters.Add(new SqlParameter("GrantRec", GrantRec));
                        command.Parameters.Add(new SqlParameter("GrantPend", GrantPend));
                        command.Parameters.Add(new SqlParameter("OtherReq", OtherReq));
                        command.Parameters.Add(new SqlParameter("OtherRec", OtherRec));
                        command.Parameters.Add(new SqlParameter("OtherPend", OtherPend));
                        command.Parameters.Add(new SqlParameter("SharedOutcome", SharedOutcome));
                        command.Parameters.Add(new SqlParameter("QuoteUse", QuoteUse));
                        command.Parameters.Add(new SqlParameter("QuoteName", QuoteName));

                        SqlParameter parmMessage = new SqlParameter("@isDuplicate", SqlDbType.Bit);
                        parmMessage.Direction = ParameterDirection.Output;
                        command.Parameters.Add(parmMessage);

                        SqlParameter parmMessage1 = new SqlParameter("@isActive", SqlDbType.Int);
                        parmMessage1.Direction = ParameterDirection.Output;
                        command.Parameters.Add(parmMessage1);

                        command.ExecuteNonQuery();

                        ViabilityMaintResult objResult = new ViabilityMaintResult();

                        objResult.IsDuplicate = DataUtils.GetBool(command.Parameters["@isDuplicate"].Value.ToString());
                        objResult.IsActive = DataUtils.GetBool(command.Parameters["@isActive"].Value.ToString());

                        return objResult;
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public static void UpdateEnterpriseEvalMilestones(int EnterpriseEvalID, int Milestone, DateTime MSDate, string Comment,
            string LeadPlanAdvisorExp, bool PlanProcess, decimal LoanReq, decimal LoanRec, decimal LoanPend, decimal GrantReq, decimal GrantRec,
            decimal GrantPend, decimal OtherReq, decimal OtherRec, decimal OtherPend, decimal SharedOutcome, decimal QuoteUse, decimal QuoteName, 
            bool RowIsActive)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConnection"].ConnectionString))
                {
                    connection.Open();

                    using (SqlCommand command = new SqlCommand())
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "UpdateEnterpriseEvalMilestones";

                        command.Parameters.Add(new SqlParameter("EnterpriseEvalID", EnterpriseEvalID));
                        command.Parameters.Add(new SqlParameter("Milestone", Milestone));
                        command.Parameters.Add(new SqlParameter("MSDate", MSDate));
                        command.Parameters.Add(new SqlParameter("Comment", Comment));
                        command.Parameters.Add(new SqlParameter("LeadPlanAdvisorExp", LeadPlanAdvisorExp));
                        command.Parameters.Add(new SqlParameter("PlanProcess", PlanProcess));
                        command.Parameters.Add(new SqlParameter("LoanReq", LoanReq));
                        command.Parameters.Add(new SqlParameter("LoanRec", LoanRec));
                        command.Parameters.Add(new SqlParameter("LoanPend", LoanPend));
                        command.Parameters.Add(new SqlParameter("GrantReq", GrantReq));
                        command.Parameters.Add(new SqlParameter("GrantRec", GrantRec));
                        command.Parameters.Add(new SqlParameter("GrantPend", GrantPend));
                        command.Parameters.Add(new SqlParameter("OtherReq", OtherReq));
                        command.Parameters.Add(new SqlParameter("OtherRec", OtherRec));
                        command.Parameters.Add(new SqlParameter("OtherPend", OtherPend));
                        command.Parameters.Add(new SqlParameter("SharedOutcome", SharedOutcome));
                        command.Parameters.Add(new SqlParameter("QuoteUse", QuoteUse));
                        command.Parameters.Add(new SqlParameter("QuoteName", QuoteName));

                        command.Parameters.Add(new SqlParameter("RowIsActive", RowIsActive));

                        command.CommandTimeout = 60 * 5;

                        command.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public static DataTable GetEnterpriseEvalMilestonesList(int ProjectID, bool IsActiveOnly)
        {
            DataTable dt = null;
            try
            {
                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConnection"].ConnectionString))
                {
                    connection.Open();

                    using (SqlCommand command = new SqlCommand())
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = "GetEnterpriseEvalMilestonesList";
                        command.Parameters.Add(new SqlParameter("ProjectID", ProjectID));
                        command.Parameters.Add(new SqlParameter("IsActiveOnly", IsActiveOnly));

                        DataSet ds = new DataSet();
                        var da = new SqlDataAdapter(command);
                        da.Fill(ds);
                        if (ds.Tables.Count == 1 && ds.Tables[0].Rows != null)
                        {
                            dt = ds.Tables[0];
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dt;
        }
    }
}
