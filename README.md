# SAS_FTIRlignin
Chemometric study trial with SAS - MP FTIR spectra and lignin chemistry - prediction of p-coumaric acid content (pcoum)



This repository explores the use of Partial Least Squares (PLS) regression in SAS, particularly for chemometric applications (e.g., spectroscopy, multivariate calibration).
⚠️ Important Caveats

Despite SAS offering a PROC PLS, this experiment highlights major limitations in its ability to perform robust chemometric modeling:
❌ Key Issues Encountered:

    No support for external test sets: PROC PLS does not allow scoring new data with a previously trained model.

    CVPRED fails silently or inconsistently: Cross-validated predictions are often not computed or lead to missing values depending on the number of factors or the validation method.

    No model persistence: The procedure does not offer a way to save and reuse trained models (store or score options are missing).

    Poor flexibility: Cross-validation is limited to basic methods (e.g., random splits, leave-one-out) and cannot be fully customized.

✅ Workaround Implemented

To bypass these issues:

    Regression coefficients were manually extracted from the OUTSTAT output table.

    Predictions on test sets were computed manually, using matrix multiplication in a DATA step or SQL logic.

    Model performance (e.g., RMSEP, R²) was evaluated separately, outside of PROC PLS.

💡 Recommendations

For anyone working in chemometrics, especially in research or production environments, consider more modern and appropriate tools:

    Python: scikit-learn's PLSRegression

    R: pls, caret, mixOmics

    Specialized software: SIMCA, The Unscrambler, PLS_Toolbox

These tools provide better handling of cross-validation, model persistence, and diagnostics—features that are essential in chemometrics.
📁 Repository Contents

    pls_train.sas – Trains a PLS model using PROC PLS.

    pls_apply_test.sas – Applies extracted coefficients to a test set.

    pls_coefficients.csv – Extracted regression weights.

    pls_predictions.csv – Predicted vs. actual values for test data.
