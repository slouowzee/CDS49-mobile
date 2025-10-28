<?php

namespace controllers;

use models\ResultatModel;
use models\EleveModel;

class ResultatController
{
    /**
     * POST /api/fin-test
     * Sauvegarde le score d'un QCM terminé.
     */
    public function finTest()
    {
        // Récupérer le token depuis l'en-tête Authorization
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        
        if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            http_response_code(401);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'status' => 'error',
                'message' => 'Token manquant ou invalide',
                'data' => null
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        $token = $matches[1];

        // Récupérer les données JSON envoyées
        $rawData = file_get_contents('php://input');
        $data = json_decode($rawData, true);

        if (!isset($data['score']) || !isset($data['nbquestions'])) {
            http_response_code(400);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'status' => 'error',
                'message' => 'Données manquantes (score, nbquestions)',
                'data' => null
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        $score = (int)$data['score'];
        $nbquestions = (int)$data['nbquestions'];

        // Sauvegarder le score via le modèle
        $resultatModel = new ResultatModel();
        $success = $resultatModel->saveScoreByToken($token, $score, $nbquestions);

        if ($success) {
            http_response_code(200);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'status' => 'success',
                'message' => 'Score enregistré avec succès',
                'data' => [
                    'score' => $score,
                    'nbquestions' => $nbquestions
                ]
            ], JSON_UNESCAPED_UNICODE);
        } else {
            http_response_code(500);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'status' => 'error',
                'message' => 'Erreur lors de l\'enregistrement du score',
                'data' => null
            ], JSON_UNESCAPED_UNICODE);
        }
    }

    /**
     * GET /api/scores
     * Récupère tous les scores d'un utilisateur avec statistiques.
     */
    public function getScores()
    {
        // Récupérer le token depuis l'en-tête Authorization
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        
        if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            http_response_code(401);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'status' => 'error',
                'message' => 'Token manquant ou invalide',
                'data' => null
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        $token = $matches[1];

        // Récupérer les paramètres de filtre (optionnels)
        $dateDebut = $_GET['date_debut'] ?? null;
        $dateFin = $_GET['date_fin'] ?? null;

        // Récupérer les scores avec statistiques
        $resultatModel = new ResultatModel();
        $data = $resultatModel->getScoresWithStatistics($token, $dateDebut, $dateFin);

        http_response_code(200);
        header('Content-Type: application/json; charset=UTF-8');
        echo json_encode([
            'status' => 'success',
            'message' => 'Scores récupérés avec succès',
            'data' => $data
        ], JSON_UNESCAPED_UNICODE);
    }
}
