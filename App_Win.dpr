program App_Win;

uses
  Vcl.Forms,
  uLog in 'uLog.pas',
  uMain_Win in 'uMain_Win.pas' {MainForm},
  uDB in 'uDB.pas',
  uConsts in 'uConsts.pas',
  uDBCustomObjects in 'uDBCustomObjects.pas',
  uLogin in 'uLogin.pas' {LoginForm},
  uProducts in 'uProducts.pas',
  uContacts in 'uContacts.pas',
  uAppTabSheet in 'uAppTabSheet.pas',
  uContactViewForm in 'uContactViewForm.pas' {ContactViewForm},
  uLocalOptions in 'uLocalOptions.pas',
  uUpdater in 'uUpdater.pas',
  uAwaitingForm in 'uAwaitingForm.pas' {AwaitingForm},
  GoogleMaps in 'GoogleMaps.pas',
  uFloatForm in 'uFloatForm.pas' {FloatForm},
  uAppForm in 'uAppForm.pas' {AppForm},
  uAppointmentViewForm in 'uAppointmentViewForm.pas' {AppointmentViewForm};

{$R *.res}

begin
  uLog.Log.CurrentProc:=uLog.Log.LogProcByName['LogToFile'];
  DoSelfUpdate;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
