package com.example.myapplication;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

import java.util.List;

public class MainActivity extends AppCompatActivity {

    private EditText emailInput, passwordInput;
    private Button signupButton, loginButton, logoutButton;
    private TextView statusText;

    private FirebaseAuth mAuth;

    private static final String FIREBASE_API_KEY = "AIzaSyCHbygWJXL1wEJ2KfE2xWcLYtd4hXg4pfg";
    private static final String FIREBASE_APP_ID = "1:948012123295:web:a2e44b5b72b655574a8eaa";
    private static final String FIREBASE_PROJECT_ID = "experiment-10-appdev";
    private static final String FIREBASE_DATABASE_URL = "https://experiment-10-appdev.firebaseapp.com";
    private static final String FIREBASE_STORAGE_BUCKET = "experiment-10-appdev.firebasestorage.app";
    private static final String FIREBASE_SENDER_ID = "948012123295";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        emailInput = findViewById(R.id.emailInput);
        passwordInput = findViewById(R.id.passwordInput);
        signupButton = findViewById(R.id.signupButton);
        loginButton = findViewById(R.id.loginButton);
        logoutButton = findViewById(R.id.logoutButton);
        statusText = findViewById(R.id.statusText);

        initializeFirebaseManually();

        mAuth = FirebaseAuth.getInstance();

        updateUI(mAuth.getCurrentUser());

        signupButton.setOnClickListener(v -> signupUser());
        loginButton.setOnClickListener(v -> loginUser());
        logoutButton.setOnClickListener(v -> logoutUser());
    }

    private void initializeFirebaseManually() {
        try {
            List<FirebaseApp> apps = FirebaseApp.getApps(this);
            if (apps == null || apps.isEmpty()) {
                FirebaseOptions options = new FirebaseOptions.Builder()
                        .setApiKey(FIREBASE_API_KEY)
                        .setApplicationId(FIREBASE_APP_ID)
                        .setProjectId(FIREBASE_PROJECT_ID)
                        .setDatabaseUrl(FIREBASE_DATABASE_URL)
                        .setStorageBucket(FIREBASE_STORAGE_BUCKET)
                        .setGcmSenderId(FIREBASE_SENDER_ID)
                        .build();

                FirebaseApp.initializeApp(this, options);
            }
        } catch (Exception e) {
            // If initialization fails, show a toast and log message
            Toast.makeText(this, "Firebase init error: " + e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

    private void signupUser() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();

        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Email and password required", Toast.LENGTH_SHORT).show();
            return;
        }

        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, task -> {
                    if (task.isSuccessful()) {
                        AuthResult result = task.getResult();
                        FirebaseUser user = result != null ? result.getUser() : null;
                        Toast.makeText(MainActivity.this, "Signup successful", Toast.LENGTH_SHORT).show();
                        updateUI(user);
                    } else {
                        String msg = task.getException() != null ? task.getException().getMessage() : "Signup failed";
                        Toast.makeText(MainActivity.this, "Signup failed: " + msg, Toast.LENGTH_LONG).show();
                    }
                });
    }

    private void loginUser() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();

        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Email and password required", Toast.LENGTH_SHORT).show();
            return;
        }

        mAuth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = mAuth.getCurrentUser();
                        Toast.makeText(MainActivity.this, "Login successful", Toast.LENGTH_SHORT).show();
                        updateUI(user);
                    } else {
                        String msg = task.getException() != null ? task.getException().getMessage() : "Login failed";
                        Toast.makeText(MainActivity.this, "Login failed: " + msg, Toast.LENGTH_LONG).show();
                    }
                });
    }

    private void logoutUser() {
        mAuth.signOut();
        updateUI(null);
        Toast.makeText(this, "Logged out", Toast.LENGTH_SHORT).show();
    }

    private void updateUI(FirebaseUser user) {
        if (user != null) {
            statusText.setText("Signed in: " + (user.getEmail() != null ? user.getEmail() : user.getUid()));
            logoutButton.setVisibility(View.VISIBLE);
        } else {
            statusText.setText("Not signed in");
            logoutButton.setVisibility(View.GONE);
        }
    }
}
